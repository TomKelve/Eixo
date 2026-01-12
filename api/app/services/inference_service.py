import os
import tempfile
from typing import List, Optional

import cv2
import numpy as np
from fastapi import UploadFile
from segment_anything import SamAutomaticMaskGenerator, sam_model_registry
import torch

from . import postprocessing, preprocessing
from .classifier_service import ClassifierService, map_to_br
from .nutrition_service import calc_kcal, calc_macros
from .portion_service import estimate_grams
from .reference_detector import ReferenceDetector
from .insights_service import save_meal_from_analyze_response
from .fitness_service import FitnessService


class InferenceService:
    def __init__(self):
        model_type = os.getenv("SAM_MODEL_TYPE", "vit_h")
        checkpoint_path = os.getenv("SAM_CHECKPOINT_PATH", "sam_vit_h_4b8939.pth")
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.max_regions = int(os.getenv("MAX_REGIONS", "8"))
        self.classifier = ClassifierService()
        self.reference_detector = ReferenceDetector()
        self.fitness_service = FitnessService()

        sam_model = sam_model_registry[model_type](checkpoint=checkpoint_path)
        sam_model.to(self.device)
        sam_model.eval()
        self.mask_generator = SamAutomaticMaskGenerator(
            model=sam_model,
            points_per_side=24,
            pred_iou_thresh=0.90,
            stability_score_thresh=0.92,
            crop_n_layers=1,
            min_mask_region_area=5000,
        )

    async def analyze(self, image: UploadFile) -> dict:
        file_bytes = await image.read()
        return await self.analyze_image(file_bytes)

    async def analyze_image(self, file_bytes: bytes) -> dict:
        image = preprocessing.load_image(file_bytes)
        resized_image = preprocessing.resize_if_needed(image)
        rgb_image = preprocessing.ensure_rgb_uint8(resized_image)

        with torch.no_grad():
            masks = self.mask_generator.generate(rgb_image)

        filtered_masks = postprocessing.filter_masks(masks)
        sorted_masks = postprocessing.sort_by_area_desc(filtered_masks)
        limited_masks = sorted_masks[: self.max_regions]

        reference_object = self.reference_detector.detect(rgb_image)
        cm_per_px = reference_object.get("scale_cm_per_px") if reference_object else None

        items: List[dict] = []
        for idx, mask in enumerate(limited_masks):
            mask_np = mask.get("segmentation")
            polygon = postprocessing.mask_to_polygon(mask_np)
            crop = postprocessing.crop_by_mask(rgb_image, mask_np)
            topk = self.classifier.predict_topk(crop, k=3)
            label_en, conf = topk[0]
            label_br = map_to_br(label_en)
            grams = None
            kcal = None
            macros = None

            if cm_per_px is not None:
                grams = estimate_grams(mask_np, cm_per_px, label_br)
                try:
                    kcal = calc_kcal(label_br, grams)
                    macros = calc_macros(label_br, grams)
                except KeyError:
                    kcal = None
                    macros = None
            items.append(
                {
                    "label": label_br,
                    "confidence": float(conf),
                    "mask_polygon": polygon,
                    "grams_estimated": grams,
                    "kcal": kcal,
                    "macros": macros,
                }
            )

        response = {
            "items": items,
            "reference_object": reference_object,
        }

        meal_log = save_meal_from_analyze_response(
            user_id="demo",
            meal_type="almoco",
            goal_mode="cutting",
            tdee=2000,
            analyze_response=response,
        )

        response["fitness"] = self.fitness_service.evaluate_meal_for_mode(
            meal_log, mode=meal_log.goal_mode
        )
        response["correction_plan"] = self.fitness_service.suggest_plate_corrections(
            meal_log, target_kcal=600
        )

        return response

    async def analyze_video(self, video: UploadFile) -> dict:
        file_bytes = await video.read()
        frame = self._extract_central_frame(file_bytes)
        if frame is None:
            return {"items": [], "reference_object": None}

        _, buffer = cv2.imencode(".jpg", frame)
        return await self.analyze_image(buffer.tobytes())

    def _extract_central_frame(self, file_bytes: bytes) -> Optional[np.ndarray]:
        with tempfile.NamedTemporaryFile(suffix=".mp4") as temp_video:
            temp_video.write(file_bytes)
            temp_video.flush()

            cap = cv2.VideoCapture(temp_video.name)
            if not cap.isOpened():
                cap.release()
                return None

            frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            if frame_count == 0:
                cap.release()
                return None

            middle_frame_idx = frame_count // 2
            cap.set(cv2.CAP_PROP_POS_FRAMES, middle_frame_idx)
            success, frame = cap.read()
            cap.release()

            if not success:
                return None

            return cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

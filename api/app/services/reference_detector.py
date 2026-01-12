"""Reference detection using COCO-scale objects.

COCO does not include utensil classes; for the MVP we use common COCO
objects as proxies for scale and will train a custom YOLO on BR utensils
in a future sprint.
"""

import numpy as np
from ultralytics import YOLO

REFERENCE_SIZES_CM = {
    "bottle": 22.0,
    "wine glass": 13.0,
    "cell phone": 15.0,
    "book": 21.0,
    "remote": 17.0,
}

TARGET_CLASSES = set(REFERENCE_SIZES_CM.keys())


class ReferenceDetector:
    def __init__(self):
        self.model = YOLO("yolov8n.pt")

    def detect(self, image_rgb: np.ndarray):
        results = self.model(image_rgb, verbose=False)[0]
        candidates = []

        for box, cls_idx in zip(results.boxes.xyxy, results.boxes.cls):
            label = results.names.get(int(cls_idx), "")
            if label not in TARGET_CLASSES:
                continue

            x1, y1, x2, y2 = box.tolist()
            w = max(x2 - x1, 0.0)
            h = max(y2 - y1, 0.0)
            area = w * h
            candidates.append((area, label, (x1, y1, w, h)))

        if not candidates:
            return None

        _, label, bbox = max(candidates, key=lambda x: x[0])
        x, y, w, h = bbox
        real_cm = REFERENCE_SIZES_CM.get(label)
        if not real_cm or h <= 0:
            return None

        cm_per_px = real_cm / h
        return {
            "type": label,
            "bbox": [float(x), float(y), float(w), float(h)],
            "scale_cm_per_px": float(cm_per_px),
        }

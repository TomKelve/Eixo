from fastapi import UploadFile
from .reference_detector import ReferenceDetector
from .nutrition_service import NutritionService
from . import reference_detector


class InferenceService:
    def __init__(self):
        self.reference_detector = ReferenceDetector()
        self.nutrition_service = NutritionService()

    async def analyze(self, image: UploadFile) -> dict:
        """Stub pipeline for MVP wiring; replace with real model calls."""
        reference = await self.reference_detector.detect(image)
        nutrition = await self.nutrition_service.estimate_nutrition(image, reference)
        return {
            "dishName": nutrition["dishName"],
            "estimatedPortionGrams": reference["portionGrams"],
            "calories": nutrition["calories"],
            "tags": nutrition["tags"],
        }

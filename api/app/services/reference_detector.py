from fastapi import UploadFile


class ReferenceDetector:
    async def detect(self, image: UploadFile) -> dict:
        """Placeholder reference detection returning a conservative portion estimate."""
        # Future: run segmentation/pose detection to find forks, plates, or coins for scale.
        return {"portionGrams": 320.0, "reference": "default_plate"}

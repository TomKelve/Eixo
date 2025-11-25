from fastapi import UploadFile


class NutritionService:
    async def estimate_nutrition(self, image: UploadFile, reference: dict) -> dict:
        """Return mocked nutrition values; replace with classifier + regressor outputs."""
        return {
            "dishName": "Feijoada",
            "calories": 780.0,
            "tags": ["beans", "pork", "rice", "farofa"],
            "reference": reference,
        }

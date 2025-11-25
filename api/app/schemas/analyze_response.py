from pydantic import BaseModel
from typing import List


class AnalyzeResponse(BaseModel):
    dishName: str
    estimatedPortionGrams: float
    calories: float
    tags: List[str]

from pydantic import BaseModel, Field
from typing import Optional


class FeedbackRequest(BaseModel):
    dish_name: str = Field(..., description="Dish name presented to the user")
    rating: int = Field(..., ge=1, le=5, description="User rating from 1-5")
    comment: Optional[str] = Field(None, description="Additional context or corrections")
    user_id: Optional[str] = Field(None, description="External user identifier")

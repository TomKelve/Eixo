from fastapi import APIRouter

router = APIRouter(prefix="/insights", tags=["insights"])


@router.get("")
async def get_insights(user_id: str):
    """Return placeholder nutrient trends until analytics is connected."""
    return {
        "userId": user_id,
        "weeklyCalories": 12340,
        "topFoods": ["Feijoada", "Tapioca", "Açaí"],
        "macros": {"carbs": 45, "protein": 28, "fat": 27},
    }

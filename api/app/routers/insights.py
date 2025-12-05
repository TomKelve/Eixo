from fastapi import APIRouter

from ..services.insights_service import InsightsService

router = APIRouter(prefix="/insights", tags=["insights"])


@router.get("")
async def get_insights(user_id: str = "demo"):
    """Return aggregated insights for the user over the last 7 days."""
    service = InsightsService()
    return service.get_insights(user_id=user_id, window_days=7)

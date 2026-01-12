from fastapi import APIRouter, Depends
from ..services.feedback_service import FeedbackService
from ..schemas.feedback_request import FeedbackRequest

router = APIRouter(prefix="/feedback", tags=["feedback"])


@router.post("")
async def submit_feedback(
    payload: FeedbackRequest,
    feedback_service: FeedbackService = Depends(FeedbackService),
):
    """Persist user corrections and comments to improve model quality."""
    await feedback_service.save_feedback(payload)
    return {"status": "received"}

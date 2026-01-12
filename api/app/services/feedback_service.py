from ..schemas.feedback_request import FeedbackRequest
from ..db.supabase_client import SupabaseClient


class FeedbackService:
    def __init__(self):
        self.client = SupabaseClient()

    async def save_feedback(self, payload: FeedbackRequest) -> None:
        """Persist feedback to Supabase; currently a stub for MVP wiring."""
        # TODO: integrate with Supabase insert once credentials are configured.
        _ = {
            "dishName": payload.dish_name,
            "rating": payload.rating,
            "comment": payload.comment,
            "userId": payload.user_id,
        }
        await self.client.log_feedback(_)

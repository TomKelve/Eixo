from fastapi import APIRouter

router = APIRouter(prefix="/history", tags=["history"])


@router.get("")
async def list_history(user_id: str):
    """Return a lightweight history list; replace with DB queries when wired."""
    return {
        "userId": user_id,
        "items": [
            {"id": "1", "dish": "Feijoada", "calories": 780},
            {"id": "2", "dish": "Moqueca", "calories": 620},
        ],
    }

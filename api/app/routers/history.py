from collections import defaultdict
from datetime import datetime, timedelta

from fastapi import APIRouter

from ..services.insights_service import FAKE_DB_MEALS

router = APIRouter(prefix="/history", tags=["history"])


@router.get("")
async def list_history(user_id: str = "demo"):
    """Return grouped meal patterns over the past week."""
    cutoff = datetime.utcnow() - timedelta(days=7)
    meals = [m for m in FAKE_DB_MEALS if m.user_id == user_id and m.datetime >= cutoff]

    pattern_stats: dict = defaultdict(list)
    for meal in meals:
        labels = sorted([item.get("label", "?") for item in meal.items])
        key = " + ".join(labels) if labels else "sem itens"
        pattern_stats[key].append(meal)

    patterns = []
    for name, grouped in pattern_stats.items():
        freq = len(grouped) / 1.0  # past 7 days ~ 1 week window
        avg_kcal = sum(m.total_kcal for m in grouped) / max(len(grouped), 1)
        avg_protein = sum(m.total_macros.get("p", 0) for m in grouped) / max(len(grouped), 1)
        patterns.append(
            {
                "name": name,
                "avg_kcal": avg_kcal,
                "avg_protein": avg_protein,
                "frequency_per_week": freq,
            }
        )

    return {"patterns": patterns}

import datetime
import uuid
from collections import defaultdict
from dataclasses import dataclass
from typing import Dict, List


@dataclass
class MealLog:
    id: str
    user_id: str
    datetime: datetime.datetime
    meal_type: str
    items: List[dict]
    total_kcal: float
    total_macros: Dict[str, float]
    goal_mode: str
    tdee: float


FAKE_DB_MEALS: List[MealLog] = []


def _aggregate_macros(items: List[dict]) -> Dict[str, float]:
    totals = {"p": 0.0, "c": 0.0, "f": 0.0}
    for item in items:
        macros = item.get("macros") or {}
        totals["p"] += float(macros.get("p", 0) or 0)
        totals["c"] += float(macros.get("c", 0) or 0)
        totals["f"] += float(macros.get("f", 0) or 0)
    return totals


def save_meal_from_analyze_response(
    user_id: str,
    meal_type: str,
    goal_mode: str,
    tdee: float,
    analyze_response: dict,
) -> MealLog:
    items = analyze_response.get("items", [])
    total_kcal = float(
        sum(float(item.get("kcal") or 0) for item in items)
    )
    total_macros = _aggregate_macros(items)
    meal_log = MealLog(
        id=str(uuid.uuid4()),
        user_id=user_id,
        datetime=datetime.datetime.utcnow(),
        meal_type=meal_type,
        items=items,
        total_kcal=total_kcal,
        total_macros=total_macros,
        goal_mode=goal_mode,
        tdee=float(tdee),
    )
    FAKE_DB_MEALS.append(meal_log)
    return meal_log


class InsightsService:
    def get_insights(self, user_id: str, window_days: int = 7) -> dict:
        now = datetime.datetime.utcnow()
        cutoff = now - datetime.timedelta(days=window_days)
        meals = [m for m in FAKE_DB_MEALS if m.user_id == user_id and m.datetime >= cutoff]

        if not meals:
            return {
                "avg_kcal_per_day": 0,
                "target_kcal_per_day": 2000,
                "avg_delta_kcal": -2000,
                "classification": "deficit_agressivo",
                "estimated_weight_change_per_week_kg": - (2000 * 7) / 7700,
                "worst_meal_type": None,
                "top_caloric_foods": [],
                "top_dense_foods": [],
            }

        kcal_per_day: Dict[str, float] = defaultdict(float)
        for meal in meals:
            day_key = meal.datetime.date().isoformat()
            kcal_per_day[day_key] += meal.total_kcal

        avg_kcal_per_day = sum(kcal_per_day.values()) / max(len(kcal_per_day), 1)
        target_kcal_per_day = (
            sum(m.tdee for m in meals) / max(len(meals), 1)
        ) if any(m.tdee for m in meals) else 2000
        avg_delta_kcal = avg_kcal_per_day - target_kcal_per_day

        classification = self._classify_delta(avg_delta_kcal)
        estimated_weight_change_per_week_kg = (avg_delta_kcal * 7) / 7700

        meal_type_delta: Dict[str, List[float]] = defaultdict(list)
        for meal in meals:
            meal_target = target_kcal_per_day / 3
            meal_type_delta[meal.meal_type].append(meal.total_kcal - meal_target)
        worst_meal_type = None
        worst_value = float('-inf')
        for m_type, deltas in meal_type_delta.items():
            avg_delta = sum(deltas) / max(len(deltas), 1)
            if avg_delta > worst_value:
                worst_value = avg_delta
                worst_meal_type = m_type

        top_caloric_foods = self._top_caloric_foods(meals)
        top_dense_foods = self._top_dense_foods(meals)

        return {
            "avg_kcal_per_day": avg_kcal_per_day,
            "target_kcal_per_day": target_kcal_per_day,
            "avg_delta_kcal": avg_delta_kcal,
            "classification": classification,
            "estimated_weight_change_per_week_kg": estimated_weight_change_per_week_kg,
            "worst_meal_type": worst_meal_type,
            "top_caloric_foods": top_caloric_foods,
            "top_dense_foods": top_dense_foods,
        }

    def _classify_delta(self, delta: float) -> str:
        if delta <= -600:
            return "deficit_agressivo"
        if delta <= -250:
            return "deficit_leve"
        if -250 < delta < 150:
            return "manutencao"
        if 150 <= delta < 450:
            return "superavit_leve"
        return "superavit_alto"

    def _top_caloric_foods(self, meals: List[MealLog]) -> List[dict]:
        calories_by_label: Dict[str, float] = defaultdict(float)
        for meal in meals:
            for item in meal.items:
                label = item.get("label") or "unknown"
                calories_by_label[label] += float(item.get("kcal") or 0)
        top = sorted(calories_by_label.items(), key=lambda x: x[1], reverse=True)[:5]
        return [{"label": k, "kcal": v} for k, v in top]

    def _top_dense_foods(self, meals: List[MealLog]) -> List[dict]:
        density_by_label: Dict[str, List[float]] = defaultdict(list)
        for meal in meals:
            for item in meal.items:
                kcal = float(item.get("kcal") or 0)
                grams = float(item.get("grams_estimated") or 0)
                if grams > 0:
                    density_by_label[item.get("label") or "unknown"].append(kcal / grams)
        avg_density = {
            label: sum(vals) / max(len(vals), 1) for label, vals in density_by_label.items()
        }
        top = sorted(avg_density.items(), key=lambda x: x[1], reverse=True)[:5]
        return [{"label": k, "kcal_per_gram": v} for k, v in top]

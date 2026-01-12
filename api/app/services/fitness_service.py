from typing import List

from .insights_service import MealLog


class FitnessService:
    def evaluate_meal_for_mode(self, meal_log: MealLog, mode: str) -> dict:
        protein = meal_log.total_macros.get("p", 0.0)
        carbs = meal_log.total_macros.get("c", 0.0)
        fat = meal_log.total_macros.get("f", 0.0)
        total_kcal = meal_log.total_kcal or 1.0

        protein_kcal = protein * 4
        carb_kcal = carbs * 4
        fat_kcal = fat * 9
        protein_ratio = protein_kcal / total_kcal
        carb_ratio = carb_kcal / total_kcal
        fat_ratio = fat_kcal / total_kcal

        diagnostics = {
            "protein_ok": False,
            "carb_ok": False,
            "fat_ok": False,
            "messages": [],
        }

        fitness_score = 5.0

        if mode == "cutting":
            diagnostics["protein_ok"] = protein_ratio >= 0.25
            diagnostics["carb_ok"] = carb_ratio <= 0.45
            diagnostics["fat_ok"] = fat_ratio <= 0.30
            fitness_score += 2 if diagnostics["protein_ok"] else -1
            fitness_score += 1 if diagnostics["carb_ok"] else -0.5
            fitness_score += 1 if diagnostics["fat_ok"] else -0.5
            diagnostics["messages"].append("Cutting mode prioritizes high protein and lower carbs/fats.")
        elif mode == "bulking":
            diagnostics["protein_ok"] = protein_ratio >= 0.20
            diagnostics["carb_ok"] = carb_ratio >= 0.45
            diagnostics["fat_ok"] = fat_ratio <= 0.35
            fitness_score += 2 if diagnostics["protein_ok"] else -1
            fitness_score += 2 if diagnostics["carb_ok"] else -1
            fitness_score += 1 if diagnostics["fat_ok"] else -0.5
            diagnostics["messages"].append("Bulking mode favors higher carbs with solid protein support.")
        else:
            diagnostics["protein_ok"] = 0.20 <= protein_ratio <= 0.35
            diagnostics["carb_ok"] = 0.35 <= carb_ratio <= 0.50
            diagnostics["fat_ok"] = 0.20 <= fat_ratio <= 0.35
            fitness_score += 1 if diagnostics["protein_ok"] else -0.5
            fitness_score += 1 if diagnostics["carb_ok"] else -0.5
            fitness_score += 1 if diagnostics["fat_ok"] else -0.5
            diagnostics["messages"].append("Maintenance mode targets balanced macros.")

        fitness_score = max(0.0, min(10.0, fitness_score))

        return {
            "fitness_score": fitness_score,
            "mode": mode,
            "diagnostics": diagnostics,
        }

    def suggest_plate_corrections(self, meal_log: MealLog, target_kcal: float) -> dict:
        current_total = meal_log.total_kcal
        needed_delta = current_total - target_kcal

        if needed_delta <= 0:
            return {
                "current_total_kcal": current_total,
                "target_kcal": target_kcal,
                "needed_delta_kcal": 0,
                "suggested_changes": [],
                "summary_text": "Prato já está dentro da meta calórica.",
            }

        items_sorted = sorted(
            meal_log.items,
            key=lambda x: (float(x.get("kcal") or 0) / max(float(x.get("grams_estimated") or 1), 1)),
            reverse=True,
        )

        suggested_changes: List[dict] = []
        remaining_delta = needed_delta

        for item in items_sorted:
            kcal = float(item.get("kcal") or 0)
            grams = float(item.get("grams_estimated") or 0)
            if grams <= 0 or kcal <= 0:
                continue
            kcal_per_gram = kcal / grams
            grams_to_reduce = min(grams * 0.7, remaining_delta / kcal_per_gram)
            remaining_delta -= grams_to_reduce * kcal_per_gram

            spoon_equiv = 0.0
            ladle_equiv = 0.0
            label = item.get("label", "")
            if "arroz" in label:
                spoon_equiv = grams_to_reduce / 30.0
            if "feij" in label:
                ladle_equiv = grams_to_reduce / 60.0

            suggested_changes.append(
                {
                    "label": label,
                    "reduce_grams": grams_to_reduce,
                    "approx_spoons": spoon_equiv,
                    "approx_ladles": ladle_equiv,
                }
            )
            if remaining_delta <= 0:
                break

        summary_text = ""
        if suggested_changes:
            parts = []
            for change in suggested_changes:
                if change["approx_spoons"] > 0:
                    parts.append(f"remova ~{change['approx_spoons']:.1f} colheres de {change['label']}")
                elif change["approx_ladles"] > 0:
                    parts.append(f"remova ~{change['approx_ladles']:.1f} conchas de {change['label']}")
                else:
                    parts.append(f"reduza {change['label']} em ~{change['reduce_grams']:.0f}g")
            summary_text = "; ".join(parts)
        else:
            summary_text = "Ajuste manual sugerido nas porções mais calóricas."

        return {
            "current_total_kcal": current_total,
            "target_kcal": target_kcal,
            "needed_delta_kcal": needed_delta,
            "suggested_changes": suggested_changes,
            "summary_text": summary_text,
        }

FOOD_NUTRITION = {
    "arroz branco": {"kcal": 130, "p": 2.5, "c": 28, "f": 0.3},
    "feijão carioca": {"kcal": 77, "p": 4.8, "c": 14, "f": 0.5},
    "frango grelhado": {"kcal": 165, "p": 31, "c": 0, "f": 3.6},
    "carne bovina grelhada": {"kcal": 217, "p": 26, "c": 0, "f": 12},
    "macarrão": {"kcal": 157, "p": 5.8, "c": 30, "f": 0.9},
    "salada": {"kcal": 20, "p": 1.2, "c": 3.6, "f": 0.2},
    "ovo": {"kcal": 155, "p": 13, "c": 1.1, "f": 11},
}


def calc_kcal(label: str, grams: float) -> float:
    kcal_100g = FOOD_NUTRITION[label]["kcal"]
    return float((grams / 100) * kcal_100g)


def calc_macros(label: str, grams: float) -> dict:
    d = FOOD_NUTRITION[label]
    return {
        "p": float((grams / 100) * d["p"]),
        "c": float((grams / 100) * d["c"]),
        "f": float((grams / 100) * d["f"]),
    }


class NutritionService:
    async def estimate_nutrition(self, image, reference: dict) -> dict:
        return {
            "dishName": None,
            "calories": None,
            "tags": [],
            "reference": reference,
        }

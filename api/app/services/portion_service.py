import numpy as np

FOOD_THICKNESS_CM = {
    "arroz branco": 1.6,
    "feijão carioca": 1.4,
    "frango grelhado": 2.8,
    "carne bovina grelhada": 2.8,
    "macarrão": 2.0,
    "salada": 1.0,
    "ovo": 2.5,
}

FOOD_DENSITY = {
    "arroz branco": 0.85,
    "feijão carioca": 1.05,
    "frango grelhado": 1.05,
    "carne bovina grelhada": 1.03,
    "macarrão": 0.95,
    "salada": 0.40,
    "ovo": 1.03,
}


def estimate_grams(mask: np.ndarray, cm_per_px: float, food_label: str) -> float:
    area_px = mask.sum()
    area_cm2 = area_px * (cm_per_px ** 2)

    thickness = FOOD_THICKNESS_CM.get(food_label, 2.0)
    density = FOOD_DENSITY.get(food_label, 1.0)

    volume_cm3 = area_cm2 * thickness
    grams = volume_cm3 * density
    return float(grams)

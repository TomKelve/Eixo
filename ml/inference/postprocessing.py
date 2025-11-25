"""Postprocessing helpers to standardize model outputs."""
from typing import Dict


def format_output(raw: Dict) -> Dict:
    """Convert raw model outputs into API-friendly schema."""
    return {
        "dishName": raw.get("dish", "unknown"),
        "estimatedPortionGrams": raw.get("portion", 0.0),
        "calories": raw.get("calories", 0.0),
        "tags": raw.get("tags", []),
    }

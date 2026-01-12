"""Inference orchestrator for EIXO models."""
from typing import Dict
from . import preprocessing, postprocessing


def predict(image_path: str) -> Dict:
    image = preprocessing.load_image(image_path)
    processed = preprocessing.normalize(image)
    # TODO: load classifier/segmenter/reference detector models.
    raw_output = {
        "dish": "feijoada",
        "portion": 420.0,
        "calories": 780.0,
        "tags": ["beans", "pork", "rice", "farofa"],
    }
    return postprocessing.format_output(raw_output)

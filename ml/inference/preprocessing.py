"""Preprocessing utilities for food images."""
from PIL import Image


def load_image(image_path: str) -> Image.Image:
    """Load image from disk with RGB conversion."""
    image = Image.open(image_path).convert("RGB")
    return image


def normalize(image: Image.Image):
    """Placeholder normalization step for MVP; replace with model-specific transforms."""
    return image

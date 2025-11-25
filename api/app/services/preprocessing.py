import io
import cv2
import numpy as np
from PIL import Image


MAX_IMAGE_SIDE = 1024


def load_image(file_bytes: bytes) -> np.ndarray:
    """Load image bytes into an RGB NumPy array."""
    with Image.open(io.BytesIO(file_bytes)) as img:
        rgb_image = img.convert("RGB")
        return np.array(rgb_image)


def resize_if_needed(image: np.ndarray) -> np.ndarray:
    """Resize image to keep the longest side under MAX_IMAGE_SIDE while preserving aspect ratio."""
    height, width = image.shape[:2]
    max_side = max(height, width)
    if max_side <= MAX_IMAGE_SIDE:
        return image

    scale = MAX_IMAGE_SIDE / float(max_side)
    new_width = int(width * scale)
    new_height = int(height * scale)
    resized = cv2.resize(image, (new_width, new_height), interpolation=cv2.INTER_AREA)
    return resized


def normalize_image(image: np.ndarray) -> np.ndarray:
    """Normalize image to uint8 RGB format that SAM expects."""
    if image.dtype != np.uint8:
        image = np.clip(image, 0, 255).astype(np.uint8)
    return image

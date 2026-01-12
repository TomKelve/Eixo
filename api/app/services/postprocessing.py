from typing import List

import cv2
import numpy as np


def mask_to_polygon(mask: np.ndarray) -> List[List[int]]:
    """Convert a boolean mask to a polygon represented as a list of [x, y] coordinates."""
    mask_uint8 = (mask.astype(np.uint8) * 255)
    contours, _ = cv2.findContours(mask_uint8, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return []

    largest_contour = max(contours, key=cv2.contourArea)
    epsilon = 0.01 * cv2.arcLength(largest_contour, True)
    approx = cv2.approxPolyDP(largest_contour, epsilon, True)
    polygon = [[int(point[0][0]), int(point[0][1])] for point in approx]
    return polygon


def filter_masks(masks: List[dict], min_area: int = 5000) -> List[dict]:
    """Remove masks smaller than the minimum area threshold."""
    return [mask for mask in masks if mask.get("area", 0) >= min_area]


def sort_by_area_desc(masks: List[dict]) -> List[dict]:
    """Sort masks in descending order by area."""
    return sorted(masks, key=lambda m: m.get("area", 0), reverse=True)


def crop_by_mask(image: np.ndarray, mask: np.ndarray, padding: int = 8) -> np.ndarray:
    """Crop the image around the mask's bounding box with padding and return RGB uint8."""
    if mask.dtype != np.uint8:
        mask_uint8 = (mask.astype(np.uint8))
    else:
        mask_uint8 = mask

    coords = cv2.findNonZero(mask_uint8)
    if coords is None:
        return image

    x, y, w, h = cv2.boundingRect(coords)
    height, width = image.shape[:2]
    x1 = max(x - padding, 0)
    y1 = max(y - padding, 0)
    x2 = min(x + w + padding, width)
    y2 = min(y + h + padding, height)

    crop = image[y1:y2, x1:x2]
    if crop.dtype != np.uint8:
        crop = np.clip(crop, 0, 255).astype(np.uint8)
    return crop

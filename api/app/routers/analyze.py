from fastapi import APIRouter, UploadFile, File, Depends
from ..services.inference_service import InferenceService
from ..schemas.analyze_response import AnalyzeResponse

router = APIRouter(prefix="/analyze", tags=["analyze"])


@router.post("", response_model=AnalyzeResponse)
async def analyze_dish(
    image: UploadFile = File(...),
    inference_service: InferenceService = Depends(InferenceService),
):
    """Receive a food photo, run the ML pipeline, and return nutrition estimates."""
    result = await inference_service.analyze(image)
    return AnalyzeResponse(**result)

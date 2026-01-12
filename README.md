# EIXO

EIXO is an AI-powered mobile platform that analyzes Brazilian dishes, estimates portions automatically, and delivers advanced nutritional data for health-conscious users and nutrition professionals.

## MVP Highlights
1. **Food vision tuned for Brazilian cuisine** covering classics like feijoada, moqueca, tapioca, and regional street food.
2. **Automatic portion estimation** using reference objects and density priors to approximate grams and milliliters.
3. **Macro and micro breakdown** with calories, carbs, proteins, fats, sodium, and fiber estimates per serving.
4. **Personalized insights** driven by user feedback loops to refine model confidence over time.
5. **Offline-first capture** with local caching before syncing analyses to the cloud.
6. **Meal history and trends** with weekly and monthly nutrient summaries.
7. **Adaptive UI** that guides better photo framing for reliable inference.
8. **Explainable predictions** with heatmaps and ingredient-level attribution where available.
9. **Secure data flow** via Supabase authentication and row-level policies.
10. **Extensible ML stack** ready for model swaps (ONNX) and A/B experiments.

## Architecture
- **Mobile (Flutter)**: Cross-platform client for capture, results visualization, insights, and feedback. Organized into screens, widgets, services, and models.
- **API (FastAPI)**: Orchestrates inference requests, manages feedback, stores history, and serves insights. Integrates with Supabase for persistence and authentication.
- **ML (Python)**: Training notebooks for classifiers, segmenters, and reference detectors; inference pipeline for preprocessing, prediction, and postprocessing; export targets for models and ONNX graphs.
- **Infra**: Docker images for API and ML workers plus helper scripts for local development.

## Running the Flutter App
1. Install Flutter (3.16+ recommended) and Dart SDK.
2. From `mobile/`, run `flutter pub get` to install dependencies.
3. Start the application with `flutter run` (emulator or connected device).
4. Configure API base URL in `lib/services/api_client.dart` if the backend is not on `localhost:8000`.

## Running the Backend (FastAPI)
1. Create a virtual environment: `python -m venv .venv && source .venv/bin/activate`.
2. Install dependencies from `api/requirements.txt`.
3. Set environment variables (e.g., `SUPABASE_URL`, `SUPABASE_KEY`, `MODEL_DIR`).
4. Start the server from `api/` with `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`.

## Training Models
- Place raw datasets under `ml/datasets/` following your chosen structure (e.g., `images/`, `labels/`).
- Use the notebooks in `ml/training/` (`train_classifier.ipynb`, `train_segmenter.ipynb`, `train_reference_detector.ipynb`) to experiment and export checkpoints.
- Update `ml/inference/preprocessing.py` with the same normalization/transforms used in training.
- Export models to `ml/exports/models/` (native) and `ml/exports/onnx/` (portable) for deployment.

## Roadmap
- **MVP**: Basic dish classification, portion estimation with a single reference object, calorie/macro estimates, feedback capture, and history tracking.
- **R1**: Multi-class ingredient segmentation, improved reference detection with edge cases (bowls, cups), and offline queueing for batch sync.
- **R2**: Personalized nutrition targets, streaks and gamification, and explainability overlays for transparency.
- **R3**: Marketplace for nutritionists, integrations with wearables, and expanded multi-language support.

## Repository Layout
- `mobile/`: Flutter application source.
- `api/`: FastAPI backend.
- `ml/`: Training and inference assets.
- `infra/`: Dockerfiles and dev scripts.


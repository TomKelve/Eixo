from fastapi import FastAPI
from .routers import analyze, feedback, history, insights

app = FastAPI(title="EIXO API", version="0.1.0")

app.include_router(analyze.router)
app.include_router(feedback.router)
app.include_router(history.router)
app.include_router(insights.router)


@app.get("/health", tags=["health"])
def healthcheck():
    return {"status": "ok"}

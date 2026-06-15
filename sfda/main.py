import logging
import os

from fastapi import FastAPI

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Demo Service",
    version="1.0.0"
)

APP_ENV = os.getenv("APP_ENV", "local")


@app.on_event("startup")
async def startup():
    logger.info("Starting Demo Service")
    logger.info("Environment: %s", APP_ENV)


@app.get("/")
async def root():
    return {
        "service": "demo-service",
        "version": "1.0.0",
        "environment": APP_ENV
    }


@app.get("/api/health")
async def health():
    return {
        "status": "healthy"
    }
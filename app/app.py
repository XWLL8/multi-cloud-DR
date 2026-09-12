
# app/main.py
from fastapi import FastAPI
from datetime import datetime
import uvicorn
import os

app = FastAPI()

@app.get("/")
def root():
    return {
        "status": "healthy",
        "region": os.getenv("REGION"),
        "cloud": os.getenv("CLOUD_PROVIDER"),  # "aws" or "gcp"
        "version": "1.0"
    }

@app.get("/health")
def health():
    # Route 53 polls this — must return 200 for health check to pass
    return {"status": "healthy"}

@app.get("/failover-status")
def failover_status():
    # Shows which cloud is active — useful for your demo
    return {
        "active_cloud": os.getenv("CLOUD_PROVIDER"),
        "region": os.getenv("REGION"),
        "timestamp": datetime.utcnow().isoformat()
    }
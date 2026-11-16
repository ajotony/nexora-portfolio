import os

from celery import Celery
from flask import Flask, jsonify, request

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")

celery = Celery(
    "nexora_publisher",
    broker=REDIS_URL,
)

app = Flask(__name__)


@app.post("/publish")
def publish():
    data = request.get_json()
    job_id = data["job_id"]

    result = celery.send_task(
        "nexora.tasks.generate_system_report",
        args=[job_id],
    )

    return jsonify({"task_id": result.id}), 202


@app.get("/health")
def health():
    return {"status": "ok"}

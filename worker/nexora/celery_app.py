import os

from celery import Celery

from .config import redis_url

celery_app = Celery("nexora", broker=redis_url())
celery_app.conf.update(
    task_default_queue=os.getenv("CELERY_QUEUE", "celery"),
    task_serializer="json",
    accept_content=["json"],
    result_backend=None,
    timezone="UTC",
)
celery_app.autodiscover_tasks(["nexora"])

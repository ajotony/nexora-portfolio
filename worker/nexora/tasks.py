import json
import socket
from datetime import datetime, timezone

from celery.utils.log import get_task_logger
from sqlalchemy import text

from .celery_app import celery_app
from .database import get_session

logger = get_task_logger(__name__)


def build_system_report(worker_name: str) -> dict[str, object]:
    """Build a deterministic, simulated operations report—no host automation occurs."""
    return {
        "summary": "System report generated successfully",
        "checks": [
            {"name": "api_connectivity", "status": "healthy"},
            {"name": "queue_availability", "status": "healthy"},
            {"name": "database_connectivity", "status": "healthy"},
        ],
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "generated_by": worker_name,
    }


@celery_app.task(name="nexora.tasks.generate_system_report", bind=True)
def generate_system_report(self, job_id: str) -> dict[str, object]:
    worker_name = socket.gethostname()
    session = get_session()
    try:
        session.execute(
            text(
                "UPDATE jobs SET status = 'processing', worker_name = :worker, "
                "started_at = now() WHERE id = :id"
            ),
            {"worker": worker_name, "id": job_id},
        )
        session.commit()
        report = build_system_report(worker_name)
        session.execute(
            text(
                "UPDATE jobs SET status = 'completed', result = CAST(:result AS jsonb), "
                "completed_at = now() WHERE id = :id"
            ),
            {"result": json.dumps(report), "id": job_id},
        )
        session.commit()
        return report
    except Exception as exc:
        session.rollback()
        logger.exception("System report job %s failed", job_id)
        session.execute(
            text(
                "UPDATE jobs SET status = 'failed', result = CAST(:result AS jsonb), "
                "completed_at = now(), worker_name = :worker WHERE id = :id"
            ),
            {
                "result": json.dumps({"error": str(exc)}),
                "worker": worker_name,
                "id": job_id,
            },
        )
        session.commit()
        raise
    finally:
        session.close()

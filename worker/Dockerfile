# Build stage
FROM python:3.12-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create isolated Python environment
RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# Production runtime
FROM python:3.12-slim AS runtime

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

# Create non-root user
RUN useradd --create-home --shell /usr/sbin/nologin nexora

# Copy Python environment from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY --chown=nexora:nexora nexora ./nexora

# Copy database migration configuration
COPY --chown=nexora:nexora alembic ./alembic
COPY --chown=nexora:nexora alembic.ini ./alembic.ini

USER nexora

CMD ["celery", "-A", "nexora.celery_app", "worker", "--loglevel=info"]

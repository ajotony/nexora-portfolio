import os
from urllib.parse import quote_plus

def database_url() -> str:
    """Return the PostgreSQL URL supplied by the runtime environment."""
    configured = os.getenv("DATABASE_URL")
    if configured:
        return configured
    required = ("DB_HOST", "DB_PORT", "DB_NAME", "DB_USER", "DB_PASSWORD")
    missing = [name for name in required if not os.getenv(name)]
    if missing:
        raise RuntimeError(f"Set DATABASE_URL or the required database variables: {', '.join(missing)}")
    host = os.environ["DB_HOST"]
    port = os.environ["DB_PORT"]
    name = os.environ["DB_NAME"]
    user = os.environ["DB_USER"]
    password = os.environ["DB_PASSWORD"]
    return f"postgresql+psycopg://{user}:{quote_plus(password)}@{host}:{port}/{name}"


def redis_url() -> str:
    return os.getenv("REDIS_URL", f"redis://{os.getenv('REDIS_HOST', 'localhost')}:{os.getenv('REDIS_PORT', '6379')}/0")

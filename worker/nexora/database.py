from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from .config import database_url

def get_session():
    """Create a database session only when a worker task actually runs."""
    engine = create_engine(database_url(), pool_pre_ping=True)
    return sessionmaker(bind=engine, expire_on_commit=False)()

"""add UUID default to jobs id

Revision ID: 20261006_0002
Revises: 20260909_0001
Create Date: 2026-10-06
"""

from alembic import op


revision = "20261006_0002"
down_revision = "20260909_0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto")
    op.execute(
        "ALTER TABLE jobs "
        "ALTER COLUMN id SET DEFAULT gen_random_uuid()"
    )


def downgrade() -> None:
    op.execute(
        "ALTER TABLE jobs "
        "ALTER COLUMN id DROP DEFAULT"
    )

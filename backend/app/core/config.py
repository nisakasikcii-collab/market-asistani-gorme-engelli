from __future__ import annotations

import os
from dataclasses import dataclass

from dotenv import load_dotenv


load_dotenv()


@dataclass(frozen=True)
class AppConfig:
    app_env: str
    app_host: str
    app_port: int
    secret_key: str
    jwt_secret_key: str
    database_url: str
    firebase_project_id: str


def get_config() -> AppConfig:
    app_port_text = os.getenv("APP_PORT", "5000")
    if not app_port_text.isdigit():
        app_port_text = "5000"

    return AppConfig(
        app_env=os.getenv("FLASK_ENV", "development"),
        app_host=os.getenv("APP_HOST", "127.0.0.1"),
        app_port=int(app_port_text),
        secret_key=os.getenv("SECRET_KEY", "unsafe-default-key"),
        jwt_secret_key=os.getenv("JWT_SECRET_KEY", "unsafe-default-jwt-key"),
        database_url=os.getenv("DATABASE_URL", "sqlite:///eyeshopper.db"),
        firebase_project_id=os.getenv("FIREBASE_PROJECT_ID", ""),
    )

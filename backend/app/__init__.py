from __future__ import annotations

from flask import Flask
from flask_jwt_extended import JWTManager

from app.api.health_routes import health_blueprint
from app.core.config import get_config
from app.core.logging import configure_logging


def create_app() -> Flask:
    config = get_config()
    configure_logging(app_env=config.app_env)

    app = Flask(__name__)
    app.config["SECRET_KEY"] = config.secret_key
    app.config["JWT_SECRET_KEY"] = config.jwt_secret_key
    app.config["SQLALCHEMY_DATABASE_URI"] = config.database_url
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    JWTManager(app)
    app.register_blueprint(health_blueprint, url_prefix="/api/v1")

    @app.get("/")
    def get_root() -> tuple[dict[str, str], int]:
        return {"message": "ES API is running"}, 200

    return app

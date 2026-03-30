from __future__ import annotations

from flask import Blueprint, jsonify


health_blueprint = Blueprint("health", __name__)


@health_blueprint.get("/health")
def get_health() -> tuple[dict[str, str], int]:
    return jsonify({"status": "ok", "service": "eyeshopper-api"}), 200

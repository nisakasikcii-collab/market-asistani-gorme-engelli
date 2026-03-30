from __future__ import annotations

from app import create_app
from app.core.config import get_config


app = create_app()


if __name__ == "__main__":
    config = get_config()
    app.run(host=config.app_host, port=config.app_port, debug=config.app_env == "development")

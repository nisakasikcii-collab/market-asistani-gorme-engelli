from __future__ import annotations

import logging


def configure_logging(*, app_env: str) -> None:
    log_level = logging.DEBUG if app_env == "development" else logging.INFO
    log_format = "%(asctime)s | %(levelname)s | %(name)s | %(message)s"
    logging.basicConfig(level=log_level, format=log_format)

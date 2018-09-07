import logging
import logging.config
from .log import MyLogRecord
import yaml
from pathlib import Path
import pytest


@pytest.fixture(scope="session", autouse=True)
def setup_logging():
    fname = Path(__file__).parent / 'logging.yaml'
    with fname.open('rt', encoding='utf-8') as f:
        cfg = yaml.load(f)
    logging.setLogRecordFactory(MyLogRecord)
    logging.config.dictConfig(cfg)

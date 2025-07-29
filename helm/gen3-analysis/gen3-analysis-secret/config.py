import os
from json import JSONDecodeError, load

from cdislogging import get_logger
from starlette.config import Config
from starlette.datastructures import Secret


ENV = os.getenv("ENV", "production")
CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
if ENV == "test":
    PATH = os.path.abspath(f"{CURRENT_DIR}/../tests/.env")
else:
    PATH = os.path.abspath(f"{CURRENT_DIR}/../.env")
config = Config(PATH)

DEBUG = config("DEBUG", cast=bool, default=False)

logger = get_logger("gen3-analysis", log_level="debug" if DEBUG else "info")

HOSTNAME = os.environ.get(
    "HOSTNAME", config("HOSTNAME", default="")
)

# gunicorn setting for the number of workers to spawn, see https://docs.gunicorn.org/en/stable/settings.html#workers
GUNICORN_WORKERS = os.environ.get(
    "GUNICORN_WORKERS", config("GUNICORN_WORKERS", default=1)
)

# Location of the policy engine service, Arborist
# Defaults to the default service name in k8s magic DNS setup
ARBORIST_URL = os.environ.get(
    "ARBORIST_URL", config("ARBORIST_URL", default="http://arborist-service")
)

# `DEPLOYMENT_TYPE` must be "prod" or "dev".
# - prod: the API reaches other Gen3 services through internal endpoints
#   (e.g., `http://guppy-service`). The API expects JWT bearer tokens in the
#   `Authorization` header.
# - dev: the API reaches other Gen3 services through external endpoints
#   (e.g., `https://<hostname>/guppy`). The API expects either JWT bearer tokens in the
#   `Authorization` header, or the Gen3 SDK to be pre-configured with credentials at
#  `~/.gen3/credentials.json`.
DEPLOYMENT_TYPE = os.environ.get(
    "DEPLOYMENT_TYPE", config("DEPLOYMENT_TYPE", cast=str, default="prod")
)
if DEPLOYMENT_TYPE not in ["prod", "dev"]:
    raise Exception(
        f'"DEPLOYMENT_TYPE" must be "prod" or "dev", got: {DEPLOYMENT_TYPE}'
    )

# `PUBLIC_ENDPOINTS` must be True or False. If True, all Gen3 Analysis API endpoints
# are publicly accessible (however, users must still have the appropriate access to
# get data from other APIs, e.g. Gen3 Guppy).
# PUBLIC_ENDPOINTS = config("PUBLIC_ENDPOINTS", cast=bool, default=False)

# /!\ only use for development! Allows running the service locally without Arborist interaction
# MOCK_AUTH = config("MOCK_AUTH", cast=bool, default=False)

#
# DB_DRIVER = config("DB_DRIVER", default="postgresql+asyncpg")
# DB_USER = config("DB_USER", default="postgres")
# DB_PASSWORD = config("DB_PASSWORD", cast=Secret, default=None)
# DB_HOST = config("DB_HOST", default="localhost")
# DB_PORT = config("DB_PORT", cast=int, default="5432")
# DB_DATABASE = config("DB_DATABASE", default="testgen3datalibrary")
#
# # postgresql://username:password@hostname:port/database_name  # pragma: allowlist secret
# DB_CONNECTION_STRING = config(
#     "DB_CONNECTION_STRING",
#     cast=Secret,
#     default=f"{DB_DRIVER}://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_DATABASE}",
# )
#
URL_PREFIX = os.environ.get(
    "URL_PREFIX", config("URL_PREFIX", default=None)
)
#
# # enable Prometheus Metrics for observability purposes
# #
# # WARNING: Any counters, gauges, histograms, etc. should be carefully
# # reviewed to make sure its labels do not contain any PII / PHI. T
# #
# # IMPORTANT: This enables a /metrics endpoint which is OPEN TO ALL TRAFFIC, unless controlled upstream
# ENABLE_PROMETHEUS_METRICS = config("ENABLE_PROMETHEUS_METRICS", default=False)
#
# PROMETHEUS_MULTIPROC_DIR = config(
#     "PROMETHEUS_MULTIPROC_DIR", default="/var/tmp/prometheus_metrics"
# )
#
# # gunicorn setting for the number of workers to spawn, see https://docs.gunicorn.org/en/stable/settings.html#workers
# GUNICORN_WORKERS = config("GUNICORN_WORKERS", default=1)
#
#
# logging = cdislogging.get_logger(__name__, log_level="debug" if DEBUG else "info")
#
# MAX_LISTS = config("MAX_LISTS", cast=int, default=100)
#
# MAX_LIST_ITEMS = config("MAX_LIST_ITEMS", cast=int, default=1000)
#
#
# def read_json_if_exists(file_path):
#     """Reads a JSON file if it exists and returns the data; returns None if the file does not exist."""
#     if not os.path.isfile(file_path):
#         logging.error("File does not exist.")
#         return None
#     with open(file_path, "r") as json_file:
#         try:
#             return load(json_file)
#         except JSONDecodeError:
#             logging.error("Error: Failed to decode JSON.")
#             return None
#
#
# SCHEMAS_LOCATION = os.path.abspath(
#     CURRENT_DIR
#     + config("SCHEMAS_LOCATION", cast=str, default="/../config/item_schemas.json")
# )
# ITEM_SCHEMAS = read_json_if_exists(SCHEMAS_LOCATION)
# if ITEM_SCHEMAS is None:
#     logging.error(f"No item schema! Schema location: {SCHEMAS_LOCATION}")
#     raise OSError("No item schema json file found!")
#
# if "None" in ITEM_SCHEMAS:
#     ITEM_SCHEMAS[None] = ITEM_SCHEMAS["None"]

# PUBLIC_ROUTES = {"/", "/_status", "/_status/", "/_version", "/_version/"}
# ENDPOINTS_WITHOUT_METRICS = {"/metrics", "/metrics/"} | PUBLIC_ROUTES
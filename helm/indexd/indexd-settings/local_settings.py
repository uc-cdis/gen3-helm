from indexd.index.drivers.alchemy import SQLAlchemyIndexDriver
from indexd.index.drivers.single_table_alchemy import SingleTableSQLAlchemyIndexDriver
from indexd.alias.drivers.alchemy import SQLAlchemyAliasDriver
from indexd.auth.drivers.alchemy import SQLAlchemyAuthDriver

from sqlalchemy.engine import URL
from sqlalchemy.pool import NullPool  # <--- CRITICAL FOR PGBOUNCER/ASYNC
from os import environ
import json

APP_NAME = "indexd"

usr = environ.get("PGUSER", "indexd")
db = environ.get("PGDB", "indexd")
psw = environ.get("PGPASSWORD")
pghost = environ.get("PGHOST")

# 1. Safely parse K8s port injections
raw_port = environ.get("PGPORT", "5432")
try:
    pgport = int(raw_port)
except Exception:
    pgport = 5432

# Prove in the pod logs that this file successfully imported without exceptions!
print(f"indexd local_settings.py loaded successfully! Targeting host: {pghost}")

db_url_obj = URL.create(
    drivername="postgresql+asyncpg",
    username=usr,
    password=psw,
    host=pghost,
    port=pgport,
    database=db
)
db_url = db_url_obj.render_as_string(hide_password=False)

index_config = {
    "DEFAULT_PREFIX": environ.get("DEFAULT_PREFIX", "testprefix/"),
    "PREPEND_PREFIX": environ.get("PREPEND_PREFIX", True),
}

CONFIG = {}
CONFIG["JSONIFY_PRETTYPRINT_REGULAR"] = False

dist = environ.get("DIST", None)
if dist:
    CONFIG["DIST"] = json.loads(dist)

arborist = environ.get("ARBORIST", "false").lower() == "true"
USE_SINGLE_TABLE = environ.get("USE_SINGLE_TABLE", "false").lower() == "true"

# 2. Add poolclass=NullPool to ALL drivers
if USE_SINGLE_TABLE:
    CONFIG["INDEX"] = {
        "driver": SingleTableSQLAlchemyIndexDriver(
            db_url,
            echo=True,
            index_config=index_config,
            poolclass=NullPool 
        )
    }
else:
    CONFIG["INDEX"] = {
        "driver": SQLAlchemyIndexDriver(
            db_url,
            echo=True,
            index_config=index_config,
            poolclass=NullPool 
        )
    }

CONFIG["ALIAS"] = {
    "driver": SQLAlchemyAliasDriver(db_url, poolclass=NullPool)
}

if arborist:
    AUTH = SQLAlchemyAuthDriver(
        db_url,
        arborist="http://arborist-service/",
        poolclass=NullPool
    )
else:
    AUTH = SQLAlchemyAuthDriver(db_url, poolclass=NullPool)

cloud_provider_map = environ.get("CLOUD_PROVIDER_MAP", None)
if cloud_provider_map:
    CONFIG["CLOUD_PROVIDER_MAP"] = json.loads(cloud_provider_map)
else:
    CONFIG["CLOUD_PROVIDER_MAP"] = {
        "s3": "aws",
        "gs": "gcp",
        "az": "azure",
    }

drs_authorization_metadata = environ.get("DRS_AUTHORIZATION_METADATA", None)
if drs_authorization_metadata:
    CONFIG["DRS_AUTHORIZATION_METADATA"] = json.loads(drs_authorization_metadata)

default_bearer_issuer = environ.get("DEFAULT_BEARER_ISSUER", None)
if default_bearer_issuer:
    CONFIG["DEFAULT_BEARER_ISSUER"] = default_bearer_issuer

default_passport_issuer = environ.get("DEFAULT_PASSPORT_ISSUER", None)
if default_passport_issuer:
    CONFIG["DEFAULT_PASSPORT_ISSUER"] = default_passport_issuer

default_preferred_type = environ.get("DEFAULT_PREFERRED_TYPE", None)
if default_preferred_type:
    CONFIG["DEFAULT_PREFERRED_TYPE"] = default_preferred_type

settings = {"config": CONFIG, "auth": AUTH}
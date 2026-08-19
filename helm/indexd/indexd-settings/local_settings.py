from indexd.index.drivers.alchemy import SQLAlchemyIndexDriver
from indexd.index.drivers.single_table_alchemy import SingleTableSQLAlchemyIndexDriver
from indexd.alias.drivers.alchemy import SQLAlchemyAliasDriver
from indexd.auth.drivers.alchemy import SQLAlchemyAuthDriver

from sqlalchemy.engine import URL
from sqlalchemy.pool import NullPool  
from os import environ
import sys
import json

APP_NAME = "indexd"

usr = environ.get("PGUSER", "indexd")
db = environ.get("PGDB", "indexd")
psw = environ.get("PGPASSWORD")
pghost = environ.get("PGHOST")

# 1. FORCE port 5432 exactly like test_conn() did to bypass PgBouncer
pgport = 5432

print(f"✅ indexd local_settings.py loaded successfully! Targeting host: {pghost} on port {pgport}", file=sys.stderr)

# 2. Keep this as a pure URL object. Do not render it as a string!
db_url = URL.create(
    drivername="postgresql+asyncpg",
    username=usr,
    password=psw,
    host=pghost,
    port=pgport,
    database=db
)

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

# Disable prepared statements for PgBouncer compatibility (just in case!)
pgbouncer_args = {
    "statement_cache_size": 0,
    "prepared_statement_cache_size": 0
}

if USE_SINGLE_TABLE:
    CONFIG["INDEX"] = {
        "driver": SingleTableSQLAlchemyIndexDriver(
            db_url,
            echo=False,
            index_config=index_config,
            poolclass=NullPool,
            connect_args=pgbouncer_args
        )
    }
else:
    CONFIG["INDEX"] = {
        "driver": SQLAlchemyIndexDriver(
            db_url,
            echo=False,
            index_config=index_config,
            poolclass=NullPool,
            connect_args=pgbouncer_args
        )
    }

CONFIG["ALIAS"] = {
    "driver": SQLAlchemyAliasDriver(db_url, poolclass=NullPool, connect_args=pgbouncer_args) 
}

if arborist:
    AUTH = SQLAlchemyAuthDriver(
        db_url,
        arborist="http://arborist-service/",
        poolclass=NullPool,
        connect_args=pgbouncer_args
    )
else:
    AUTH = SQLAlchemyAuthDriver(db_url, poolclass=NullPool, connect_args=pgbouncer_args) 

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
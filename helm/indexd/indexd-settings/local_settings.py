from indexd.index.drivers.alchemy import SQLAlchemyIndexDriver
from indexd.index.drivers.single_table_alchemy import SingleTableSQLAlchemyIndexDriver
from indexd.alias.drivers.alchemy import SQLAlchemyAliasDriver
from indexd.auth.drivers.alchemy import SQLAlchemyAuthDriver

from sqlalchemy.engine import URL  # <--- Added URL import
from os import environ
import json

APP_NAME = "indexd"

usr = environ.get("PGUSER", "indexd")
db = environ.get("PGDB", "indexd")
psw = environ.get("PGPASSWORD")
pghost = environ.get("PGHOST")
pgport = environ.get("PGPORT", 5432)

# Build the URL safely and render it to a string for the drivers
db_url_obj = URL.create(
    drivername="postgresql+asyncpg",
    username=usr,
    password=psw,
    host=pghost,
    port=int(pgport),
    database=db
)
db_url = db_url_obj.render_as_string(hide_password=False)

# TODO: FIX THIS TO READ FROM ENV VARS
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

if USE_SINGLE_TABLE:
    CONFIG["INDEX"] = {
        "driver": SingleTableSQLAlchemyIndexDriver(
            db_url,
            echo=True,
            index_config=index_config
        )
    }
else:
    CONFIG["INDEX"] = {
        "driver": SQLAlchemyIndexDriver(
            db_url,
            echo=True,
            index_config=index_config
        )
    }

CONFIG["ALIAS"] = {
    "driver": SQLAlchemyAliasDriver(db_url)
}

if arborist:
    AUTH = SQLAlchemyAuthDriver(
        db_url,
        arborist="http://arborist-service/",
    )
else:
    AUTH = SQLAlchemyAuthDriver(db_url)

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
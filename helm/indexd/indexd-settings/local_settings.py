from indexd.index.drivers.alchemy import SQLAlchemyIndexDriver
from indexd.index.drivers.single_table_alchemy import SingleTableSQLAlchemyIndexDriver
from indexd.alias.drivers.alchemy import SQLAlchemyAliasDriver
from indexd.auth.drivers.alchemy import SQLAlchemyAuthDriver


from os import environ
import json

APP_NAME = "indexd"


usr = environ.get("PGUSER", "indexd")
db = environ.get("PGDB", "indexd")
psw = environ.get("PGPASSWORD")
pghost = environ.get("PGHOST")
pgport = environ.get("PGPORT", 5432)

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

# - DEFAULT_PREFIX: prefix to be prepended.
# - PREPEND_PREFIX: the prefix is preprended to the generated GUID when a
#   new record is created WITHOUT a provided GUID.
# - ADD_PREFIX_ALIAS: aliases are created for new records - "<PREFIX><GUID>".
# Do NOT set both ADD_PREFIX_ALIAS and PREPEND_PREFIX to True, or aliases
# will be created as "<PREFIX><PREFIX><GUID>".
if USE_SINGLE_TABLE:
    CONFIG["INDEX"] = {
        "driver": SingleTableSQLAlchemyIndexDriver(
            "postgresql+psycopg2://{usr}:{psw}@{pghost}:{pgport}/{db}".format(
                usr=usr, psw=psw, pghost=pghost, pgport=pgport, db=db
            ),
            echo=True,
            index_config=index_config
        )
    }
else:
    CONFIG["INDEX"] = {
        "driver": SQLAlchemyIndexDriver(
            "postgresql+psycopg2://{usr}:{psw}@{pghost}:{pgport}/{db}".format(
                usr=usr, psw=psw, pghost=pghost, pgport=pgport, db=db
            ),
            echo=True,
            index_config=index_config
        )
    }


CONFIG["ALIAS"] = {
    "driver": SQLAlchemyAliasDriver(
        "postgresql+psycopg2://{usr}:{psw}@{pghost}:{pgport}/{db}".format(
            usr=usr, psw=psw, pghost=pghost, pgport=pgport, db=db
        )
    )
}

if arborist:
    AUTH = SQLAlchemyAuthDriver(
        "postgresql+psycopg2://{usr}:{psw}@{pghost}:{pgport}/{db}".format(
            usr=usr, psw=psw, pghost=pghost, pgport=pgport, db=db
        ),
        arborist="http://arborist-service/",
    )
else:
    AUTH = SQLAlchemyAuthDriver(
        "postgresql+psycopg2://{usr}:{psw}@{pghost}:{pgport}/{db}".format(
            usr=usr, psw=psw, pghost=pghost, pgport=pgport, db=db
        )
    )

settings = {"config": CONFIG, "auth": AUTH}

from indexd.index.drivers.alchemy import SQLAlchemyIndexDriver
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

CONFIG["INDEX"] = {
    "driver": SQLAlchemyIndexDriver(
        "postgresql+psycopg2://{usr}:{psw}@{pghost}:{pgport}/{db}".format(
            usr=usr, psw=psw, pghost=pghost, pgport=pgport, db=db
        ),
        index_config=index_config,
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

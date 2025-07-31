from peregrine.api import app, app_init
from os import environ
import bin.confighelper as confighelper

APP_NAME = "peregrine"


def load_json(file_name):
    return confighelper.load_json(file_name, APP_NAME)


conf_data = load_json("creds.json")
config = app.config


# ARBORIST deprecated, replaced by ARBORIST_URL
# ARBORIST_URL is initialized in app_init() directly
config["ARBORIST"] = "http://arborist-service/"


config["INDEX_CLIENT"] = {
    "host": environ.get("INDEX_CLIENT_HOST") or "http://indexd-service",
    "version": "v0",
    # The user should be "sheepdog", but for legacy reasons, we use "gdcapi" instead
    "auth": (
        (
            environ.get("INDEXD_USER", "gdcapi"),
            environ.get("INDEXD_PASS")
            or conf_data.get("indexd_password", "{{indexd_password}}"),
        )
    ),
}

config["PSQLGRAPH"] = {
    "host": environ.get("PGHOST") or conf_data.get("db_host", "{{db_host}}"),
    "user": environ.get("PGUSER") or conf_data.get("db_username", "{{db_username}}"),
    "password": environ.get("PGPASSWORD")
    or conf_data.get("db_password", "{{db_password}}"),
    "database": environ.get("PGDB") or conf_data.get("db_database", "{{db_database}}"),
}

fence_username = environ.get("FENCE_DB_USER") or conf_data.get(
    "fence_username", "{{fence_username}}"
)
fence_password = environ.get("FENCE_DB_PASS") or conf_data.get(
    "fence_password", "{{fence_password}}"
)
fence_host = environ.get("FENCE_DB_HOST") or conf_data.get(
    "fence_host", "{{fence_host}}"
)
fence_database = environ.get("FENCE_DB_DBNAME") or conf_data.get(
    "fence_database", "{{fence_database}}"
)
config["PSQL_USER_DB_CONNECTION"] = "postgresql://%s:%s@%s:5432/%s" % (
    fence_username,
    fence_password,
    fence_host,
    fence_database,
)


config["DICTIONARY_URL"] = environ.get(
    "DICTIONARY_URL",
    "https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json",
)

hostname = environ.get("CONF_HOSTNAME") or conf_data["hostname"]
config["OIDC_ISSUER"] = "https://%s/user" % hostname

config["USER_API"] = config["OIDC_ISSUER"]  # for use by authutils
# use the USER_API URL instead of the public issuer URL to accquire JWT keys
config["FORCE_ISSUER"] = True
app_init(app)
application = app
application.debug = environ.get("GEN3_DEBUG") == "True"
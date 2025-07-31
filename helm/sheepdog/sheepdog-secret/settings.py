from sheepdog.api import app, app_init
from os import environ
import confighelper

APP_NAME = "sheepdog"


def load_json(file_name):
    return confighelper.load_json(file_name, APP_NAME)


conf_data = load_json("creds.json")
config = app.config

config["AUTH"] = "https://auth.service.consul:5000/v3/"
config["AUTH_ADMIN_CREDS"] = None
config["INTERNAL_AUTH"] = None

# ARBORIST deprecated, replaced by ARBORIST_URL
# ARBORIST_URL is initialized in app_init() directly
config["ARBORIST"] = "http://arborist-service/"

# Signpost: deprecated, replaced by index client.
config["SIGNPOST"] = {
    "host": environ.get("SIGNPOST_HOST") or "http://indexd-service",
    "version": "v0",
    "auth": ("gdcapi", conf_data.get("indexd_password", "{{indexd_password}}")),
}
config["INDEX_CLIENT"] = {
    "host": environ.get("INDEX_CLIENT_HOST") or "http://indexd-service",
    "version": "v0",
    "auth": ("gdcapi", conf_data.get("indexd_password", "{{indexd_password}}")),
}
config["FAKE_AUTH"] = False
config["PSQLGRAPH"] = {
    "host": environ.get("PGHOST"),
    "user": environ.get("PGUSER"),
    "password": environ.get("PGPASSWORD"),
    "database": environ.get("PGDB"),
}

config["FLASK_SECRET_KEY"] = conf_data.get("gdcapi_secret_key", "{{gdcapi_secret_key}}")
config['PSQL_USER_DB_CONNECTION'] = 'postgresql://%s:%s@%s:5432/%s' % (environ.get("FENCE_DB_USER"), environ.get("FENCE_DB_PASS"), environ.get("FENCE_DB_HOST"), environ.get("FENCE_DB_DBNAME"))

config["BASE_URL"] = "https://%s/user" % conf_data["hostname"] # for use by authutils remove when authutils gets updated 
config["USER_API"] = "http://fence-service/"  # for use by authutils og: "https://%s/user" % conf_data["hostname"]
# use the USER_API URL instead of the public issuer URL to accquire JWT keys
config["FORCE_ISSUER"] = True
config["DICTIONARY_URL"] = environ.get(
    "DICTIONARY_URL",
    "https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json",
)

app_init(app)
application = app
application.debug = environ.get("GEN3_DEBUG") == "True"
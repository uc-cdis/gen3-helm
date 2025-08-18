from PcdcAnalysisTools.api import app, app_init
from os import environ
import bin.confighelper as confighelper
from pcdcutils.environment import is_env_enabled

APP_NAME='PcdcAnalysisTools'
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
    "host": conf_data.get("db_host", environ.get("PGHOST", "localhost")),
    "user": conf_data.get("db_username", environ.get("PGUSER", "sheepdog")),
    "password": conf_data.get("db_password", environ.get("PGPASSWORD", "sheepdog")),
    "database": conf_data.get("db_database", environ.get("PGDB", "sheepdog")),
}

config["FLASK_SECRET_KEY"] = conf_data.get("gdcapi_secret_key", "{{gdcapi_secret_key}}")
fence_username = conf_data.get(
    "fence_username", environ.get("FENCE_DB_USER", "fence")
)
fence_password = conf_data.get(
    "fence_password", environ.get("FENCE_DB_PASS", "fence")
)
fence_host = conf_data.get("fence_host", environ.get("FENCE_DB_HOST", "localhost"))
fence_database = conf_data.get(
    "fence_database", environ.get("FENCE_DB_DATABASE", "fence")
)
config["PSQL_USER_DB_CONNECTION"] = "postgresql://%s:%s@%s:5432/%s" % (
    fence_username,
    fence_password,
    fence_host,
    fence_database,
)

hostname = conf_data.get(
    "hostname", environ.get("CONF_HOSTNAME", "localhost")
)  # for use by authutils
config["OIDC_ISSUER"] = "https://%s/user" % hostname
if hostname == "localhost":
    config["USER_API"] = "http://fence-service/"
else:
    config["USER_API"] = "https://%s/user" % hostname  # for use by authutils

# config['USER_API'] = 'http://fence-service/'
# option to force authutils to prioritize USER_API setting over the issuer from
# token when redirecting, used during local docker compose setup when the
# services are on different containers but the hostname is still localhost
config['FORCE_ISSUER'] = True

config["DICTIONARY_URL"] = environ.get(
    "DICTIONARY_URL",
    "https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json",
)

# trailing slash intentionally omitted
config['GUPPY_API'] = 'http://guppy-service'
config["FENCE"] = 'http://fence-service'
config['SERVICE_NAME'] = 'pcdcanalysistools'
config['PRIVATE_KEY_PATH'] = "/var/www/PcdcAnalysisTools/jwt_private_key.pem"
config["AUTH"] = "https://auth.service.consul:5000/v3/"
config["AUTH_ADMIN_CREDS"] = None
config["INTERNAL_AUTH"] = None
config["FAKE_AUTH"] = False
config["HMAC_ENCRYPTION_KEY"] = conf_data.get("hmac_key", environ.get("HMAC_ENCRYPTION_KEY"))

config['SURVIVAL'] = {
    'consortium': ["INSTRuCT", "INRG", "MaGIC", "NODAL"],
    'excluded_variables': [
        {
            'label': 'Data Contributor',
            'field': 'data_contributor_id',
        },
        {
            'label': 'Study',
            'field': 'studies.study_id',
        },
        {
            'label': 'Treatment Arm',
            'field': 'studies.treatment_arm',
        }
    ],

    'result': {
        'risktable': True,
        'survival': True
    }
}

config['TABLE_ONE'] = {
    'consortium': ["INSTRuCT", "INRG", "MaGIC", "NODAL"],
    'excluded_variables': [
        {
            'label': 'Data Contributor',
            'field': 'data_contributor_id',
        },
        {
            'label': 'Study',
            'field': 'studies.study_id',
        },
        {
            'label': 'Treatment Arm',
            'field': 'studies.treatment_arm',
        }
    ],

    'result': {
        "enabled": True
    }
}

config['EXTERNAL'] = {
    'commons': [
        {
            'label': 'Genomic Data Commons',
            'value': 'gdc'
        },
        {
            'label': 'Gabriella Miller Kids First',
            'value': 'gmkf'
        }
    ], 
    "commons_dict": {
        "gdc": "TARGET - GDC", 
        "gmkf": "GMKF"
    }
}

app_init(app)
application = app
application.debug = (is_env_enabled('GEN3_DEBUG'))
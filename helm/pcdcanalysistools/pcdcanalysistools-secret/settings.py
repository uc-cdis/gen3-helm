from PcdcAnalysisTools.api import app, app_init
from os import environ
#import config_helper
from pcdcutils.environment import is_env_enabled

APP_NAME='PcdcAnalysisTools'
# def load_json(file_name):
#     return config_helper.load_json(file_name, APP_NAME)


# conf_data = load_json("creds.json")
config = app.config

config['SERVICE_NAME'] = 'pcdcanalysistools'
config['PRIVATE_KEY_PATH'] = "/var/www/PcdcAnalysisTools/jwt_private_key.pem"

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
    "auth": ("gdcapi", environ.get( "INDEXD_PASS") ),
}
config["INDEX_CLIENT"] = {
    "host": environ.get("INDEX_CLIENT_HOST") or "http://indexd-service",
    "version": "v0",
    "auth": ("gdcapi", environ.get( "INDEXD_PASS") ),
}
config["FAKE_AUTH"] = False
config["PSQLGRAPH"] = {
    'host': environ.get( "PGHOST"),
    'user': environ.get( "PGUSER"),
    'password': environ.get( "PGPASSWORD"),
    'database': environ.get( "PGDB"),
}

# config["HMAC_ENCRYPTION_KEY"] = conf_data.get("hmac_key", "{{hmac_key}}")
# config["FLASK_SECRET_KEY"] = conf_data.get("gdcapi_secret_key", "{{gdcapi_secret_key}}")
config["HMAC_ENCRYPTION_KEY"] = environ.get( "HMAC_ENCRYPTION_KEY")
config["FLASK_SECRET_KEY"] = environ.get( "FLASK_SECRET_KEY")
fence_username = environ.get( "FENCE_DB_USER")
fence_password = environ.get( "FENCE_DB_PASS")
fence_host = environ.get( "FENCE_DB_HOST")
fence_database = environ.get( "FENCE_DB_DBNAME")
config['PSQL_USER_DB_CONNECTION'] = 'postgresql://%s:%s@%s:5432/%s' % (fence_username, fence_password, fence_host, fence_database)

hostname = environ.get("CONF_HOSTNAME", "localhost")
config['OIDC_ISSUER'] = 'https://%s/user' % hostname

config["OAUTH2"] = {
   "client_id": 'conf_data.get("oauth2_client_id", "{{oauth2_client_id}}")',
    "client_secret": 'conf_data.get("oauth2_client_secret", "{{oauth2_client_secret}}")',
    "api_base_url": "https://%s/user/" % hostname,
    "authorize_url": "https://%s/user/oauth2/authorize" % hostname,
    "access_token_url": "https://%s/user/oauth2/token" % hostname,
    "refresh_token_url": "https://%s/user/oauth2/token" % hostname,
    "client_kwargs": {
        "redirect_uri": "https://%s/api/v0/oauth2/authorize" % hostname,
        "scope": "openid data user",
    },
    # deprecated key values, should be removed after all commons use new oidc
    "internal_oauth_provider": "http://fence-service/oauth2/",
    "oauth_provider": "https://%s/user/oauth2/" % hostname,
    "redirect_uri": "https://%s/api/v0/oauth2/authorize" % hostname,
}

# trailing slash intentionally omitted
config['GUPPY_API'] = 'http://guppy-service'

config["USER_API"] = config["OIDC_ISSUER"]  # for use by authutils
# config['USER_API'] = 'http://fence-service/'
# option to force authutils to prioritize USER_API setting over the issuer from
# token when redirecting, used during local docker compose setup when the
# services are on different containers but the hostname is still localhost
config['FORCE_ISSUER'] = True

if environ.get('DICTIONARY_URL'):
    config['DICTIONARY_URL'] = environ.get('DICTIONARY_URL')
else:
    config['PATH_TO_SCHEMA_DIR'] = environ.get('PATH_TO_SCHEMA_DIR')

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
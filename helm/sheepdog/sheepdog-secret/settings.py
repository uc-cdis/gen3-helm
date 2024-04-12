#####################################################
# DO NOT CHANGE THIS FILE                           #
# config updates should be done in the service code #
#####################################################

from sheepdog.api import app, app_init
from os import environ
# import config_helper

APP_NAME='sheepdog'
# def load_json(file_name):
#   return config_helper.load_json(file_name, APP_NAME)

# conf_data = load_json('creds.json')
config = app.config


config['INDEX_CLIENT'] = {
    'host': environ.get('INDEX_CLIENT_HOST') or 'http://indexd-service',
    'version': 'v0',
    'auth': (environ.get( "INDEXD_USER", 'sheepdog'), environ.get( "INDEXD_PASS") ),
}

config["PSQLGRAPH"] = {
    'host': environ.get( "PGHOST"),
    'user': environ.get( "PGUSER"),
    'password': environ.get( "PGPASSWORD"),
    'database': environ.get( "PGDB"),
}

config['HMAC_ENCRYPTION_KEY'] = environ.get( "HMAC_ENCRYPTION_KEY")
config['FLASK_SECRET_KEY'] = environ.get( "FLASK_SECRET_KEY")

fence_username = environ.get( "FENCE_DB_USER")
fence_password = environ.get( "FENCE_DB_PASS")
fence_host = environ.get( "FENCE_DB_HOST")
fence_database = environ.get( "FENCE_DB_DBNAME")
config['PSQL_USER_DB_CONNECTION'] = 'postgresql://%s:%s@%s:5432/%s' % (fence_username, fence_password, fence_host, fence_database)

config['DICTIONARY_URL'] = environ.get('DICTIONARY_URL','https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json')


# config['SUBMISSION'] = {
#     'bucket': conf_data.get( 'bagit_bucket', '{{bagit_bucket}}' )
# }

# config['STORAGE'] = {
#     "s3":
#     {
#         "access_key": conf_data.get( 's3_access', '{{s3_access}}' ),
#         'secret_key': conf_data.get( 's3_secret', '{{s3_secret}}' )
#     }
# }

hostname = environ.get("CONF_HOSTNAME", "localhost")

config['OIDC_ISSUER'] = 'https://%s/user' % hostname

config['OAUTH2'] = {
    'client_id': "conf_data.get('oauth2_client_id', '{{oauth2_client_id}}')",
    'client_secret': "conf_data.get('oauth2_client_secret', '{{oauth2_client_secret}}')",
    'api_base_url': 'https://%s/user/' % hostname,
    'authorize_url': 'https://%s/user/oauth2/authorize' % hostname,
    'access_token_url': 'https://%s/user/oauth2/token' % hostname,
    'refresh_token_url': 'https://%s/user/oauth2/token' % hostname,
    'client_kwargs': {
        'redirect_uri': 'https://%s/api/v0/oauth2/authorize' % hostname,
        'scope': 'openid data user',
    },
    # deprecated key values, should be removed after all commons use new oidc
    'internal_oauth_provider': 'http://fence-service/oauth2/',
    'oauth_provider': 'https://%s/user/oauth2/' % hostname,
    'redirect_uri': 'https://%s/api/v0/oauth2/authorize'  % hostname
}

config['USER_API'] = environ.get('FENCE_URL') or 'http://fence-service/'
# use the USER_API URL instead of the public issuer URL to accquire JWT keys
config['FORCE_ISSUER'] = True
print(config)
app_init(app)
application = app
application.debug = (environ.get('GEN3_DEBUG') == "True")

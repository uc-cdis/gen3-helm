import os
import json
from boto.s3.connection import OrdinaryCallingFormat


DB = "postgresql://test:test@localhost:5432/amanuensis"

MOCK_AUTH = False
MOCK_STORAGE = False

SERVER_NAME = "http://localhost/user"
BASE_URL = SERVER_NAME
APPLICATION_ROOT = "/user"

ROOT_DIR = "/amanuensis"

# If using multi-tenant setup, configure this to the base URL for the provider
# amanuensis (i.e. ``BASE_URL`` in the provider amanuensis config).
# OIDC_ISSUER = 'http://localhost:8080/user


HMAC_ENCRYPTION_KEY = ""



"""
If the api is behind firewall that need to set http proxy:
    HTTP_PROXY = {'host': 'cloud-proxy', 'port': 3128}
"""
HTTP_PROXY = None
STORAGES = ["/cleversafe"]




SESSION_COOKIE_SECURE = False
ENABLE_CSRF_PROTECTION = True

INDEXD = "/index"

INDEXD_AUTH = ("gdcapi", "")

ARBORIST = "/rbac"

AWS_CREDENTIALS = {
    "CRED1": {"aws_access_key_id": "", "aws_secret_access_key": ""},
    "CRED2": {"aws_access_key_id": "", "aws_secret_access_key": ""},
}

ASSUMED_ROLES = {"arn:aws:iam::role1": "CRED1"}

DATA_UPLOAD_BUCKET = "bucket1"

S3_BUCKETS = {
    "bucket1": {"cred": "CRED1"},
    "bucket2": {"cred": "CRED2"},
    "bucket3": {"cred": "CRED1", "role-arn": "arn:aws:iam::role1"},
}


APP_NAME = ""



# dir_path = "/secrets"
# fence_creds = os.path.join(dir_path, "fence_credentials.json")


# SUPPORT_EMAIL_FOR_ERRORS = None
# dbGaP = {}
# if os.path.exists(fence_creds):
#     with open(fence_creds, "r") as f:
#         data = json.load(f)
#         AWS_CREDENTIALS = data["AWS_CREDENTIALS"]
#         S3_BUCKETS = data["S3_BUCKETS"]
#         OIDC_ISSUER = data["OIDC_ISSUER"]
#         APP_NAME = data["APP_NAME"]
#         HTTP_PROXY = data["HTTP_PROXY"]
#         dbGaP = data["dbGaP"]

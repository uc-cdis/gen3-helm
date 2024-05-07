import click
import requests
import os
import urllib3

from ssl import create_default_context, Purpose
from zipfile import ZipFile
from io import BytesIO
from datetime import datetime
from re import search
from shutil import make_archive, rmtree
from getpass import getpass


OHSU_SECRET_SERVER_ENDPOINT = "https://secretserver.ohsu.edu/secretserver"


# See 'Domain' on https://secretserver.ohsu.edu/SecretServer/login.aspx
DOMAIN = "OHSUM01"
SECRETS_LOCAL = 17583
SECRETS_DEV = 17220
SECRETS_CBDS = 17599
SECRETS_STAGING = 17600
SECRETS_PROD = 17601
SECRETS_CBDS_DEV = 17602


@click.group()
def cli():
    """Secret Server CLI"""
    pass


class CustomHttpAdapter (requests.adapters.HTTPAdapter):
    """Python 3.12 uses openSSL v3 which doesn't allow for
        unsafe legacy renegotiation. Secretserver endpoint is
        making me have to use unsafe legacy renegotiation"""

    def __init__(self, ssl_context=None, **kwargs):
        self.ssl_context = ssl_context
        super().__init__(**kwargs)

    def init_poolmanager(self, connections, maxsize, block=False):
        self.poolmanager = urllib3.poolmanager.PoolManager(
            num_pools=connections, maxsize=maxsize,
            block=block, ssl_context=self.ssl_context)


def get_legacy_session():
    ctx = create_default_context(Purpose.SERVER_AUTH)
    ctx.options |= 0x4  # OP_LEGACY_SERVER_CONNECT
    session = requests.session()
    session.mount('https://', CustomHttpAdapter(ctx))
    return session


def conv_shorthand(env: str) -> str:
    "Converts shorthand names to actual env names"
    if env == "dev":
        return "development"
    if env == "prod":
        return "production"
    if env == "cbds-dev":
        return "cbds_dev"
    return env


def match_env_with_id(env: str, id: int):
    """Secret Server expects an 'id' in order to get data from a secret.
       To do this you need to"""

    conv_env = conv_shorthand(env)
    prefix = "Secrets-"
    if id is not None:
        return id, f"{prefix}{conv_env}"

    if conv_env == "local":
        return SECRETS_LOCAL, f"{prefix}local"
    if conv_env == "development":
        return SECRETS_DEV, f"{prefix}development"
    if conv_env == "staging":
        return SECRETS_STAGING, f"{prefix}staging"
    if conv_env in ["production", "prod"]:
        return SECRETS_PROD, f"{prefix}production"
    if conv_env in ["cbds", "CBDS"]:
        return SECRETS_CBDS, f"{prefix}cbds"
    if conv_env in ["cbds-dev", "CBDS-DEV"]:
        return SECRETS_CBDS_DEV, f"{prefix}cbds_dev"


def _fetch_cached_token() -> str:
    """Looks for SS token files.
       Returns a token if the name of the file is within 20 minutes
       of creation. Otherwise returns empty string"""
    pattern = r"\.SSToken\.\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{6}"
    cwd = os.getcwd()
    for filename in os.listdir(cwd):
        match = search(pattern, filename)
        if match:
            filepath = os.path.join(cwd, filename)
            if os.path.exists(filepath):
                token_time_str = match.group().split(".SSToken.")[-1]
                try:
                    token_time = datetime.strptime(token_time_str,
                                                   "%Y-%m-%d %H:%M:%S.%f")
                    time_difference = datetime.now() - token_time
                    if time_difference.total_seconds() < 1200:
                        with open(filepath, "r") as valid_token:
                            token = valid_token.readline()
                            return token, filepath

                    # If token exists but it is invalid, delete it
                    elif time_difference.total_seconds() > 1200:
                        os.unlink(filepath)
                        return "", ""

                except Exception as e:
                    print("Exception: ", e)
                    return "", ""
    return "", ""


@cli.command("list")
@click.option('--username', '-u',
              default=None, help='Username')
# You don't need to specify password, click will ask for it when this is setup
@click.option('--password', '-p',  # prompt=True, hide_input=True,
              default=None, help='Password')
@click.option('--otp', '-o',
              default=None, help='One time Password. Duo app.')
def get_secrets_list(username: str, password: str, otp: int):
    _get_secrets_list(username, password, otp)


def _get_secrets_list(username: str, password: str, otp: int):
    """Lists basic information in of secrets that can be used to
       fetch the actual secret"""
    token = _get_token(username, password, otp)
    try:
        session = get_legacy_session()
        headers = {"Authorization": f"Bearer {token}"}
        response = session.get(f"{OHSU_SECRET_SERVER_ENDPOINT}/api/v2/secrets",
                               headers=headers)

        json_response = response.json()
        if "records" in json_response and len(json_response["records"]) > 0:
            print(f"id{'':13}name{'':36}secretTemplateName{'':2}folderId")
            for elem in json_response["records"]:
                print(f"{str(elem['id']):15}{elem['name']:40}{elem['secretTemplateName']:20}{elem['folderId']}")
        else:
            print("JSON response contains no records: \n", json_response)
        response.raise_for_status()

    except requests.exceptions.RequestException as e:
        response_body = e.response.json() if e.response else None
        error_message = response_body.get("error") if response_body else str(e)
        print(f"ERROR: {error_message}")
        exit(1)


@cli.command("get")
@click.argument('env', required=True)
@click.option('--username', '-u',
              default=None, help='Username')
@click.option('--password', '-p',
              default=None, help='Password')
@click.option('--id', '-i',
              default=None, help='The secret id in secret server.\
The full list of secrets can be viewed by running a "list" command.')
@click.option('--otp', '-o',
              default=None, help='One time Password. Duo app.')
def get_secret(username: str, password: str, env: str, id: int, otp: int):
    _replace_local_secrets(username, password, env, id, otp)


def _replace_local_secrets(username: str, password: str,
                           env: str, id: int, otp: int):
    """Fetches the Secrets directory from SS.
       Replaces the old ss directory"""
    token = _get_token(username, password, otp)
    try:
        session = get_legacy_session()
        headers = {"Authorization": f"Bearer {token}"}
        id, env_dir = match_env_with_id(env, id)

        response = session.get(f"{OHSU_SECRET_SERVER_ENDPOINT}/api/v1/secrets/\
{id}/fields/file",
                               headers=headers)
        response.raise_for_status()

        if os.path.islink("Secrets"):
            os.unlink("Secrets")
        if os.path.isdir(env_dir):
            rmtree(env_dir)

        with BytesIO(response.content) as zip_buffer:
            with ZipFile(zip_buffer, 'r') as zip_ref:
                zip_ref.extractall(env_dir)

        os.symlink(env_dir, "Secrets", target_is_directory=True)
        return

    except requests.exceptions.RequestException as e:
        response_body = e.response.json() if e.response else None
        error_message = response_body.get("error") if response_body else str(e)
        print(f"ERROR: {error_message}")
        exit(1)


@cli.command("post")
@click.argument('env', required=True)
@click.option('--username', '-u',
              default=None, help='Username')
@click.option('--password', '-p',
              default=None, help='Password')
@click.option('--id', '-i',
              default=None, help='The secret id in secret server.\
The full list of secrets can be viewed by running a "list" command.')
@click.option('--otp', '-o',
              default=None, help='One time Password. Duo app.')
def update_secret(env: str, username: str, password: str, id: int, otp: int):
    _update_secret(env, username, password, id, otp)


def _update_secret(env: str, username: str, password: str, id: int, otp: int):
    token = _get_token(username, password, otp)
    try:
        session = get_legacy_session()
        headers = {"Authorization": f"Bearer {token}"}
        id, env_dir = match_env_with_id(env, id)

        if os.path.exists(env_dir):
            make_archive(env_dir, 'zip', env_dir)
            with open(f"{env_dir}.zip", mode="rb") as f:
                data = f.read()
                os.unlink(f"{env_dir}.zip")
        else:
            raise FileNotFoundError(f"Secrets directory: {env_dir}.zip does\
not exist")

        files = {'file': (os.path.basename(f"{env_dir}.zip"), data)}
        response = session.put(f"{OHSU_SECRET_SERVER_ENDPOINT}/api/v1/secrets/{id}/fields/file",
                               data={'fileName': f"{env_dir}.zip"},
                               headers=headers, files=files)

        print(response.content)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        response_body = e.response.json() if e.response else None
        error_message = response_body.get("error") if response_body else str(e)
        print(f"ERROR: {error_message}")
        exit(1)


@cli.command("token")
@click.option('--username', '-u',
              default=None, help='Username')
@click.option('--password', '-p',
              default=None, help='Password')
@click.option('--otp', '-o',
              default=None, help='One time Password. Duo app.')
def get_token(username: str, password: str, otp: int):
    _get_token(username, password, otp)


def _get_token(username: str, password: str, otp: int) -> str:
    """Token fetcher. Checks cache and if cache is empty
       authenticates to server and returns a token"""
    cached_token, filepath = _fetch_cached_token()
    if cached_token != "" and filepath != "":
        print(f"Cached Token: {cached_token}\nFilepath: {filepath}\n")
        return cached_token

    if not username:
        username = input("Enter your username: ")
    if not password:
        password = getpass(prompt="Enter your password: ")

    creds = {
        "username": username,
        "password": password,
        "domain": DOMAIN,
        "grant_type": "password",
    }
    if otp is None:
        otp = input("Enter your OTP for 2FA: ")
    headers = {'OTP': otp}
    try:
        session = get_legacy_session()
        response = session.post(f"{OHSU_SECRET_SERVER_ENDPOINT}/oauth2/token",
                                data=creds, headers=headers)
        response.raise_for_status()
        token = response.json().get("access_token")

        filepath = f".SSToken.{datetime.now()}"
        with open(filepath, "w") as token_writer:
            token_writer.write(str(token))
            print(f"Fresh Token: {token}\nFilepath: {filepath}\n")

        return token
    except requests.exceptions.RequestException as e:
        response_body = e.response.json() if e.response else None
        error_message = response_body.get("error") if response_body else str(e)
        if "Failed to resolve 'secretserver.ohsu.edu'" in str(e):
            print("You must be connected to the secure network in order to access secretserver.ohsu.edu")
            exit(1)
        elif "400 Client Error: Bad Request for url: https://secretserver.ohsu.edu/secretserver/oauth2/token" in str(e):
            print("Invalid login credentials.")
        else:
            print(f"ERROR: {error_message}")
            exit(1)


if __name__ == '__main__':
    cli()

# Creating and Using Gen3 Certs in Helm

In this directory we have a `development.aced-idp.org.crt` and `development.aced-idp.org.key` file that together make up the SSL certification used for our site (https://aced-training.compbio.ohsu.edu for development purposes). These files can then be plugged into the `gen3-certs.yaml` file and included in subsequent `helm upgrade` commands.

## 1. Add the certificate and key values

```yaml
global:
  tls:
    cert: |
      <development.aced-idp.org.crt>
    key: |
      <development.aced-idp.org.key>
```

*Note*: This `tls.cert` and `tls.key` configuration will be passed by Helm into `helm/revproxy/templates/tls.yaml` and must match the key-value format found in that file.

## 2. Use the new yaml file in Helm

```sh
helm upgrade --install local ./helm/gen3 \
    -f Secrets values.yaml \
    -f Secrets/user.yaml \
    -f Secrets/fence-config.yaml \
    -f Secrets/TLS/gen3-certs.yaml
```

The 'myCA' files are the Certificate Authority backing the actual TLS certificates. Importing the myCA.pem file into the macOS keyring allows us to access https://development.aced-idp.org in the browser.

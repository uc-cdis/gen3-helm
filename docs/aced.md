# Instructions for ACED Gen3 Deployment

## Install Rancher

Install Rancher Desktop from [Github Releases page](https://github.com/rancher-sandbox/rancher-desktop/releases/latest)

See docs/gen3_developer_environments.md regarding setting vm.max_map_count.

Note: after restarting rancher desktop, you will need to ensure this value is still set.

```
echo 'sudo sysctl -p' | rdctl shell
```

## Install Kubernetes

```sh
brew install kubectl
```

## Install Helm

```sh
brew install helm
helm repo add gen3 https://helm.gen3.org
helm repo update
```

## Aced specific files:

* gitops.json - Controls windmill UI configuration - see values.yaml
  Gitops values are encoded as a json string under portal.gitops.json
  ```
  portal:
  ...  
  # -- (map) GitOps configuration for portal
    gitops:
      # -- (string) multiline string - gitops.json
      json: |

  ```

* fence-config.yaml - Authentication config. Same as legacy compose services file except addition of header
    ```
    fence:
    FENCE_CONFIG:
        APP_NAME:
        ...
    ```
* user.yaml - Authorization config. Same as legacy compose services file except addition of header, note contents are a yaml string
    ```
    fence:
    USER_YAML: |
        ...
    ```

* certs
    *See [OneDrive](https://ohsuitg-my.sharepoint.com/:f:/r/personal/walsbr_ohsu_edu/Documents/compbio-tls?csf=1&web=1&e=7oFdxd)*

    Copy the keys into the `gen3-certs.yaml` file.

    ```
    cp Secrets/TLS/gen3-certs-example.yaml Secrets/TLS/gen3-certs.yaml
    cat service.* >> Secrets/TLS/gen3-certs.yaml
    # Then match the key-key value formats in the file
    ```

## Deploy

```sh
# Clone gen3-helm 
git clone https://github.com/ACED-IDP/gen3-helm
git checkout feature/etl

# uninstall previous version
helm uninstall local
# update dependencies
helm dependency update helm/gen3

# Start deployment 
helm upgrade --install local ./helm/gen3 -f values.yaml -f user.yaml -f fence-config.yaml -f Secrets/TLS/gen3-certs.yaml

```

## Add SSL Certs to ingress

Replace the tls.crt and tls.key with the contents of  service-base64.crt, service-base64.key.

```sh
cat service.crt | base64 > service-base64.crt
cat service.key | base64 > service-base64.key
KUBE_EDITOR="code -w" kubectl edit secrets gen3-certs
```

### Alternate Method

```sh
kubectl delete secrets gen3-certs
kubectl create secret tls gen3-certs --key=Secrets/TLS/service.key --cert=Secrets/TLS/service.crt
```

## Increase Elasticsearch Memory

As referenced in the [Gen3 developer docs](gen3_developer_environments.md#elasticsearch-error), Elasticsearch may output an error regarding too low of `max virtual memory` --

```
ERROR: [1] bootstrap checks failed
[1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```

To fix this we'll open a shell into the Rancher Desktop node and update the required memory fields -- 

```sh
rdctl shell

sudo sysctl -w vm.max_map_count=262144
sudo sh -c 'echo "vm.max_map_count=262144" >> /etc/sysctl.conf'

sysctl vm.max_map_count
# vm.max_map_count = 262144
```

## Add ETL Pod

> Login to browser first, download credentials.json to Secrets/credentials.json

```sh
kubectl delete configmap credentials
kubectl create configmap credentials --from-file Secrets
kubectl delete pod etl
kubectl apply -f etl.yaml
sleep 10
# kubectl describe pod etl
kubectl exec --stdin --tty etl -- /bin/bash
```

## Bucket setup

> Unlike our compose services environment, where docker-compose was responsible for Gen3 and S3 (minio) configurations,  our k8s environment only has responsibility for Gen3 services and dependencies.   S3, whether AWS or Minio based is handled externally.

### Current staging setup

* OHSU - minio setup documented [here](https://ohsuitg-my.sharepoint.com/:t:/r/personal/walsbr_ohsu_edu/Documents/aced-1-minio.md?csf=1&web=1&e=iL5PmW)

* ucl, manchester, stanford

  * create buckets
  ![image](https://user-images.githubusercontent.com/47808/230643703-358ccacc-e974-4140-b0e6-7f080b90d484.png)

  * grant permissions to a AWS IAM user representing fence.
  ![image](https://user-images.githubusercontent.com/47808/230643891-df980b9c-eddf-45c4-93ed-7dff2c27cb34.png)

  * see fence-config.yaml:
     * `AWS_CREDENTIALS: {}`  aws_access_key_id, aws_secret_access_key
     * `S3_BUCKETS: {}`  bucket_name, cred, region

## Helpful Command

### Listing Secrets

```sh
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq
```

### Counting pods neither Running or Completed

```sh
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed  | grep -v NAMES | wc -l
```

### Manually change SSL certificate

The SSL certificate and key file are automatically handled by the `Secrets/TLS/gen3-certs.yaml` and invoked in the `helm upgrade` command. However if you wish change the certificate or key for any reason simply delete the `gen3-certs` secret and recreate it with the `crt` and `key` file you wish to use:

```sh
kubectl delete secrets gen3-certs
kubectl create secret tls gen3-certs --cert=Secrets/TLS/service.crt --key=Secrets/TLS/service.key
```
### TODO - Create env varaiables instead of files in etl.yaml 

```sh

export PGDB=`cat /creds/sheepdog-creds/database`
export PGPASSWORD=`cat /creds/sheepdog-creds/password`
export PGUSER=`cat /creds/sheepdog-creds/username`
export PGHOST=`cat /creds/sheepdog-creds/host`
export DBREADY=`cat /creds/sheepdog-creds/dbcreated`
export PGPORT=`cat /creds/sheepdog-creds/port`

echo e.g. Connecting $PGUSER:$PGPASSWORD@$PGHOST:$PGPORT//$PGDB if $DBREADY  
```

# Local Development

1. Add IP address from ingress to `/etc/hosts`

* NOTE: Appending the IP address from ingress and not removing any of the other IP addresses like
 127.0.0.1 aced-training.compbio.ohsu.edu is an important detail to mention. Also, after this IP has been added,
 in order to see changes you should redo the certs:
 
  ```
  kubectl delete secrets gen3-certs
  kubectl create secret tls gen3-certs --key=Secrets/TLS/service.key --cert=Secrets/TLS/service.crt
  ```
  before testing curl http://aced-training.compbio.ohsu.edu from inside and outside the cluster.

  Another handy command for debugging this is 
  ```
  kubectl logs -n kube-system deployment/traefik
  ```

`kubectl get ingress`
```
NAME           CLASS     HOSTS                      ADDRESS         PORTS     AGE
revproxy-dev   traefik   development.aced-idp.org   192.168.205.2   80, 443   50m
```

`/etc/hosts`
```
# Local ACED development
192.168.205.2 development.aced-idp.org
```

2. Import the Certificate Authority (CA) file into a macOS keychain. This keychain can be one from the list of 'Default Keychains' (e.g. 'login'). Alternatively, create a custom keychain that will be used for development in order to avoid modifying existing records.

- New Keychain... > ACED-development > Enter new passphrase for this keychain

- Select the ACED-development keychain

- File > Import Items... > Select the MyCA.pem file

- Right click the certificate > Get Info > Trust > Change 'When using this certificate:' to Always Trust

https://development.aced-idp.org should now load normally with no SSL errors.

# Process for generating SSL certs for local development

Create SSL Certs for development.aced-idp.org ([reference](https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate)):

```
cd helm/revproxy/ssl
chmod +x generate_certs.sh
./generate_certs.sh
```

This will output:
- the certificate files for development.aced-idp.org:
    - development.aced-idp.org.crt
    - development.aced-idp.org.key
- the certificate authority files that can be imported into the user's keyring:
    - MyCA.pem

## Add SSL Certs to ingress

Replace the tls.crt and tls.key with the contents of  service-base64.crt, service-base64.key.

```sh
cat service.crt | base64 > service-base64.crt
cat service.key | base64 > service-base64.key
KUBE_EDITOR="code -w" kubectl edit secrets gen3-certs
```

### Alternate Method

```sh
kubectl delete secrets gen3-certs
kubectl create secret tls gen3-certs --key=Secrets/TLS/service.key --cert=Secrets/TLS/service.crt
```


## Switch to AWS k8s Context

```sh
export AWS_DEFAULT_PROFILE=staging

aws eks update-kubeconfig --region us-west-2 --name aced-commons
# Updated context arn:aws:eks:us-west-2:119548034047:cluster/aced-commons in /Users/beckmanl/.kube/config

kubectl config get-contexts
# CURRENT   NAME                                                      CLUSTER                                                   AUTHINFO                                                  NAMESPACE
# *         arn:aws:eks:us-west-2:119548034047:cluster/aced-commons   arn:aws:eks:us-west-2:119548034047:cluster/aced-commons   arn:aws:eks:us-west-2:119548034047:cluster/aced-commons
#           rancher-desktop                                           rancher-desktop                                           rancher-desktop
```

## Switch to Local (Rancher Desktop) k8s Context
```sh
# To switch to the local k8s context
kubectl config use-context rancher-desktop
# Switched to context "rancher-desktop".
```

# Cloud Automation

```sh
# cat ~/.aws/config
# [default]
# output = json
# region = us-west-2
# credential_source = Ec2InstanceMetadata
# 
# [profile staging]
# output = json
# region = us-west-2
# role_arn = arn:aws:iam::119548034047:role/ACC-8940
# source_profile=staging
gen3 workon staging aced-commons-development

gen3 cd

# Error: Error applying plan:
# 1 error occurred:
#         * module.cdis_vpc.module.data-bucket.aws_s3_bucket_public_access_block.data_bucket_logs_privacy: 1 error occurred:
#         * aws_s3_bucket_public_access_block.data_bucket_logs_privacy: error creating public access block policy for S3 bucket (aced-commons-development-data-bucket-logs):
#           OperationAborted: A conflicting conditional operation is currently in progress against this resource. Please try again.
#         status code: 409, request id: 1ECNA18CDJ3X66B7, host id: NoZFqs6p83VksCvABLLepDbWHxPZql6itf96D7pfp1fPExm4SbPehk9AByMqjc/o73gaPmyv7Ys=
gen3 tfplan
gen3 tfapply

# To delete resources on AWS
# gen3 tfplan --destroy
```

## RDS (Aurora)

### Engine options

`Show versions that support Serverless v2`
Aurora MySQL 3.02.0 (compatible with MySQL 8.0.23)

### Instance configuration

DB instance class
`Serverless v2`

Minimum ACUs
`0.5 (1 GiB)`

Maximum ACUs
`10 (20 GiB)`

### Settings

DB cluster identifier
aced-commons-development-aurora

Manage master credentials in AWS Secrets Manager

### Availability & durability

Create an Aurora Replica or Reader node in a different AZ (recommended for scaled availability)
Creates an Aurora Replica for fast failover and high availability.

### Connectivity

Don’t connect to an EC2 compute resource

Virtual private cloud (VPC)
`aced-commons-development`

Public Access
`No`

VPC security group (firewall)
`Choose Existing`

Existing VPC security groups
`Local`, `Default`

### Database authentication

Password and IAM database authentication

### Additional Configuration

Backup retention period
`14 days`

Target Backtrack window
`48 hours`

Select the log types to publish to Amazon CloudWatch Logs
`PostgreSQL log`

Log exports
- `Audit log`
- `Error log`
- `General log`
- `Slow query log`

Deletion protection
`Enable`

---

Add to `values.yaml`:

```yaml
global:
  # RDS configuration
  postgres:
    master:
      # Writer instance endpoint
      host: "foo-aurora.rds.amazonaws.com"
      username: <POSTGRES USERNAME>
      password: <POSTGRES PASSWORD>
      port: 5432
```

## ElasticSearch (OpenSearch)

```json
{
    "DomainName": "aced-commons-development-es",
    "AdvancedSecurityOptions": {
        "MasterUserOptions": {
            "MasterUserName": "<MASTER USERNAME>",
            "MasterUserPassword": "<MASTER USER PASSWORD>"
        }
    },
    "VPCOptions": {
      "SubnetIds": ["subnet-foo"],
      "SecurityGroupIds": ["sg-foo"] 
    }
}
```

```sh
aws opensearch create-domain --cli-input-json file://es_domain.json
```

---

Add to `values.yaml`:

```yaml
# OpenSearch configuration
aws-es-proxy:
  enabled: true
  # Endpoint
  esEndpoint: vpc-foo.es.amazonaws.com
  secrets:
    awsAccessKeyId: "<ACCESS KEY ID>"
    awsSecretAccessKey: "<SECRET ACCESS KEY>"
```

## Certificate
  - Validation

## Ingress (Load Balancer)

## RDS/PostgreSQL

```sh
root@etl:/# env | grep PG
PGPORT=5432
PGPASSWORD=foo
GPG_KEY=baz
PGUSER=sheepdog_local
PGDB=sheepdog_local
PGHOST=foo-aurora.rds.amazonaws.com
```

```
psql -U postgres -W
```

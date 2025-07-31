# Gen3 Services

# Ambassador

## What Does it Do

Ambassador is an envoy proxy. We use this service to direct traffic toward our workspaces, hatchery and jupyter containers.

## How to Configure it

For a full set of configuration see the [helm README.md for ambassador](../helm/ambassador/README.md) or read the [values.yaml](../helm/ambassador/values.yaml) directly

Example configuration using gen3 umbrella chart:

```yaml
ambassador:
  # Whether or not to deploy the service or not
  enabled: true

  # What image/ tag to pull
  image:
    repository: quay.io/datawire/ambassador
    tag: "1.4.2"
    pullPolicy: Always
```


## Extra Information

Ambassador is only necessary if there is a hatchery deployment, as this is used as an envoy proxy primarily for workspaces. This may change in the future. 

---

# aws-es-proxy

## What Does it Do

The aws-es-proxy is a proxy for hitting the elasticsearch service running in AWS. It is required for guppy, ETL and metadata, if you are running managed elasticsearch in AWS, as they leverage this pod to talk to elasticsearch.

## How to Configure it


For a full set of configuration see the [helm README.md for aws-es-proxy](../helm/aws-es-proxy/README.md) or read the [values.yaml](../helm/aws-es-proxy/values.yaml) directly


Some important configuration items for `aws-es-proxy` in helm:

```yaml
# -- AWS user to use to connect to ES 
aws-es-proxy:
  # Whether or not to deploy the service or not
  enabled: true

  # What image/ tag to pull
  image:
    repository:
    tag: 
  
  # AWS secrets 
  secrets:
    awsAccessKeyId: ""
    awsSecretAccessKey: ""

  # Elasticsearch endpoint in AWS
  esEndpoint: test.us-east-1.es.amazonaws.com
```


## Extra Information

This pod can also be used to make direct queries to elastic search. If you know you want to make a manaul query to elastic search. You can exec into the aws-es-proxy pod and run the following, filling in the appropriate endpoint you want to hit to query elasticsearch.

```bash
curl http://localhost:9200/
```

---

# Arborist

## What Does it Do

Arborist is the authorization service. It works with fence to assign authortizations to a user based on their authentication information. Information around user authorizations are set within a useryaml, or telemetry file for dbgap authorized users, and put into the arborist db during usersync.

## How to configure it

For a full set of configuration see the [helm README.md for arborist](../helm/arborist/README.md) or read the [values.yaml](../helm/arborist/values.yaml) directly

Some configuration options include:
-  postgres configuration 
- image repo/ tag


```yaml
arborist:
  # Whether or not to deploy the service or not
  enabled: true

  # What image/ tag to pull
  image:
    tag:
    repository:
```

## Extra Information

[Find common arborist database queries here](https://github.com/uc-cdis/cdis-wiki/blob/master/dev/gen3-sql-queries.md#arborist-database).

---

# Fence

## What Does it Do

Fence is a core service for a gen3 datacommons which handles authentication. It is necessary for a commons to run and will handle authentication on the /login endpoint as well as creating presigned url's in the presigned-url-fence pods.

## How to Configure it


```yaml
fence:
  # Whether or not to deploy the service or not
  enabled: true

  # What image/ tag to pull
  image:
    tag:
    repository:
  
  # FENCE_CONFIG
  FENCE_CONFIG:
    OPENID_CONNECT:
      google:
        client_id: "insert.google.client_id.here"
        client_secret: "insert.google.client_secret.here"

  # -- (string) USER YAML. Passed in as a multiline string.
  USER_YAML: |
    <the contents of your user.yaml here>


```

You need to ensure a proper working fence-config file. Fence is highly configurable and a lot of config is commons specific, but some important fields to configure are as follows.

1. BASE_URL
  * This should be (the url of the commons)/user.
2. DB
  * This should contain the psql connection string, which should contain the correct database, user, password and hostname.
3. OPENID_CONNECT
  * This is where different IdP's can be configured. To be able to leverage an IdP as a login option you need to add the client id's/secrets and any other necesary config to the predefined blocks.
4. ENABLED_IDENTITY_PROVIDERS/LOGIN_OPTIONS
  * Use one of these blocks to enable/configure buttons for logging into the IdP's defined in the OPENID_CONNECT block.
5. DEFAULT_LOGIN_IDP/DEFAULT_LOGIN_URL
  * These blocks will define the default login option, which will be used by most external oidc clients.
6. dbGaP
  * This will be used to connect to an sftp server which will contain telemetry files for usersync. Is necessary for setting up authorizations outside of the useryaml.
7. AWS_CREDENTIALS/S3_BUCKETS/DATA_UPLOAD_BUCKET
 * The AWS_CREDENTIALS block will define credentials for service accounts used to access s3 buckets. The s3 buckets are defined in the S3_BUCKETS block, which will reference a credential in the AWS_CREDENTIALS block. The DATA_UPLOAD_BUCKET block defines the data upload bucket, which is the bucket used in the data upload flow, to upload files to a commons.
8. CIRRUS_CFG
  * If google buckets are used you need to configure this block. It is used to setup the google bucket workflow, which essentially creates google users and google bucket access groups, which get filled with users and added to bucket policies to allow implicit access to users.

For more infomation, [see this](https://github.com/uc-cdis/fence/blob/master/fence/config-default.yaml)


A user.yaml will control access to your data commons. To see how to construct a user.yaml properly:

https://github.com/uc-cdis/fence/blob/master/docs/additional_documentation/user.yaml_guide.md 

## Extra Information

### Fence Pods

Fence is split into 2 deployments. There is the regular fence deployment which handles commons authentication. We also split the presigned url feature of fence into a seperate deployment, the presigned-url-fence deployment. They will both get setup/deployed with a gen3 installation.

### Troubleshooting Fence

There are [some commons sql queries that can be found here](https://github.com/uc-cdis/cdis-wiki/blob/master/dev/gen3-sql-queries.md#fence-database). 

### Setting up OIDC clients

OIDC (OpenID Connect) clients allow applications to authenticate with Fence. This setup is often necessary for external users who want to integrate their applications with Gen3. For each application, you'll need to create a unique OIDC client, which will provide a client_id and client_secret for the application to use.

Once the client is created, share the client_id and client_secret with the application owner so they can configure their application to authenticate with Fence. To create these clients, you will need to exec into a fence container and run the [following commands](https://github.com/uc-cdis/fence/blob/master/docs/additional_documentation/setup.md#register-oauth-client).


---

# Guppy

## What Does it Do

Guppy is used to render the explorer page. It uses elastic search indices to render the page.

## How to Configure it


For a full set of configuration see the [helm README.md for guppy](../helm/guppy/README.md) or read the [values.yaml](../helm/guppy/values.yaml) directly


There is also config that needs to be set within the global block around the tier access level, defining how the explorer page should handle displaying unauthorized files, and the limit to how far unauthorized user can filter down files. Last, there is a guppy block that needs to be configured with the elastic search indices guppy will use to render the explorer page.

```
global:
  tierAccessLevel: "(libre|regular|private)"

guppy:
  # -- (int) Only relevant if tireAccessLevel is set to "regular". 
  # The minimum amount of files unauthorized users can filter down to
  tierAccessLimit: "1000"

  # -- (list) Elasticsearch index configurations
  indices:
    - index: dev_case
      type: case
    - index: dev_file
      type: file

  # -- (string) The Elasticsearch configuration index
  configIndex: dev_case-array-config
  # -- (string) The field used for access control and authorization filters
  authFilterField: auth_resource_path
  # -- (bool) Whether or not to enable encryption for specified fields
  enableEncryptWhitelist: true
  # -- (string) A comma-separated list of fields to encrypt
  encryptWhitelist: test1


  # -- (string) Elasticsearch endpoint.
  # defaults to "elasticsearch:9200"
  esEndpoint: ""
```


You will also need a mapping file to map the fields you want to pull from postgres into the elasticsearch indices. There are too many fields to describe here, but [an example mapping file can be found here](https://github.com/uc-cdis/cdis-manifest/blob/master/gen3.biodatacatalyst.nhlbi.nih.gov/etlMapping.yaml).

Last, guppy works closely with portal to render the explorer page. You will need to ensure a proper [dataExplorer block](https://github.com/uc-cdis/cdis-manifest/blob/master/gen3.biodatacatalyst.nhlbi.nih.gov/portal/gitops.json#L212) is setup within the gitops.json file, referencing fields that have been pulled from postgres into the elasticsearch indices.

## Extra Information

Guppy relies on indices being created to run, if there are no indices created guppy will fail to start up. 

To create these indices you can run etl, however a valid ETL mapping file needs to be created and data needs to be submitted to the commons. 


---
# Hatchery

## What Does it Do

Hatchery is used to create workspaces. It contains information about workspaces images and resources set around those images to run.

## How to Configure it


For a full set of configuration see the [helm README.md for hatchery](../helm/hatchery/README.md) or read the [values.yaml](../helm/hatchery/values.yaml) directly


```
hatchery:
  enabled: true
  image:
    repository:
    tag:


  # -- (map) Hatchery sidcar container configuration.
  hatchery:
    sidecarContainer:
      cpu-limit: '0.1'
      memory-limit: 256Mi
      image: quay.io/cdis/ecs-ws-sidecar:master

      env:
        NAMESPACE: "{{ .Release.Namespace }}"
        HOSTNAME: "{{ .Values.global.hostname }}"

      args: []

      command:
      - "/bin/bash"
      - "./sidecar.sh"

      lifecycle-pre-stop:
      - su
      - "-c"
      - echo test
      - "-s"
      - "/bin/sh"
      - root

    containers:
      - target-port: 8888
        cpu-limit: '1.0'
        memory-limit: 2Gi
        name: "(Tutorials) Example Analysis Jupyter Lab Notebooks"
        image: quay.io/cdis/heal-notebooks:combined_tutorials__latest
        env:
          FRAME_ANCESTORS: https://{{ .Values.global.hostname }}
        args:
        - "--NotebookApp.base_url=/lw-workspace/proxy/"
        - "--NotebookApp.default_url=/lab"
        - "--NotebookApp.password=''"
        - "--NotebookApp.token=''"
        - "--NotebookApp.shutdown_no_activity_timeout=5400"
        - "--NotebookApp.quit_button=False"
        command:
        - start-notebook.sh
        path-rewrite: "/lw-workspace/proxy/"
        use-tls: 'false'
        ready-probe: "/lw-workspace/proxy/"
        lifecycle-post-start:
        - "/bin/sh"
        - "-c"
        - export IAM=`whoami`; rm -rf /home/$IAM/pd/dockerHome; rm -rf /home/$IAM/pd/lost+found;
          ln -s /data /home/$IAM/pd/; true
        user-uid: 1000
        fs-gid: 100
        user-volume-location: "/home/jovyan/pd"
        gen3-volume-location: "/home/jovyan/.gen3"
```


## Extra Information

---

# Indexd

## What Does it Do

Indexd is a core service of the commons. It is used to index files within the commons, to be used by fence to download data.

## How to Configure it

For a full set of configuration see the [helm README.md for indexd](../helm/indexd/README.md) or read the [values.yaml](../helm/indexd/values.yaml) directly


```yaml
indexd:
  enabled: true

  image: 
    repository:
    tag:
  
  # default prefix that gets added to all indexd records.
  defaultPrefix: "TEST/"

  # Secrets for fence and sheepdog to use to authenticate with indexd.
  # If left blank, will be autogenerated.
  secrets:
    userdb:
      fence:
      sheepdog:
```

## Extra Information

Indexd is used to hold information regarding files in the commons. We can index any files we want, but should ensure that bucket in indexd are configured within fence, so that downloading the files will work. To index files We have a variety of tools. First, data upload will automatically create indexd records for files uploaded. If we want to index files from external buckets we can also use [indexd-utils](https://github.com/uc-cdis/indexd_utils), or if the commons has dirm setup, create a manifest and upload it to the /indexing endpoint of a commons. From there GUID's will be created and/or assigned to objects. You can view the information about the records by hitting the (commons url)/index/(GUID) endpoint. To test that the download works for these files you will want to hit the (commons url)/user/data/download/(GUID) endpoint, while ensuring you user has the proper access to the ACL/Authz assigned to the indexd record.

# Manifestservice

## What Does it Do

The manifestservice is used by the workspaces to mount files to a workspace. Workspace pods get setup with a sidecar container which will  mount files to the data directory. This is used so that users can access files directly on the worskpace container. The files pulled are defined by manifests, created through the export to workspace button in the explorer page. These manifests live in an s3 bucket which the manifestservice can query.

## How to Configure it



## Extra Information

---
# Metadata

## What Does it Do

The Metadata Service provides an API for retrieving JSON metadata of GUIDs. It is a flexible option for "semi-structured" data (key:value mappings).

The GUID (the key) can be any string that is unique within the instance. The value is the metadata associated with the GUID, it’s a JSON blob whose structure is not enforced on the server side.



## How to Configure it


```
manifestservice:
  enabled: true

  manifestserviceG3auto:
    hostname: testinstall
    # -- (string) Bucket for the manifestservice to read and write to.
    bucketName: testbucket
    # -- (string) Directory name to use within the s3 bucket.
    prefix: test
    # -- (string) AWS access key.
    awsaccesskey: ""
    # -- (string) AWS secret access key.
    awssecretkey: ""
```

## Extra Information


---
# Peregrine

## What Does it Do

The peregrine service is used to query data in postgres. It works similar to guppy, but relies on querying postgres directly. It will create the charts on the front page of the commons, as well as the /query endpoint of a commons.

## How to Configure it

To configure peregrine we require an entry in the versions block. It also requires a dictionary in the global block.


```yaml
```


## Extra Information


---

# Portal

## What Does it Do

Portal is a core service that renders the complete commons webpage, it is the front end service.

## How to Configure it

To configure portal we require an entry in the versions block. The portal_app also needs to be defined in the global block. Gitops sets to use the files in the ~/cdis-manifest/(commons url)/ portal directory, dev is the common setup for development environments and [there are default gitops.json](https://github.com/uc-cdis/data-portal/tree/master/data/config) files for most commons that the portal app can be set to.

```yaml
portal:
  enabled: true

  gitops:
    # -- (string) multiline string - gitops.json
    json: |
      {}
    # -- (string) - favicon in base64
    favicon: ""
    # -- (string) - multiline string - gitops.css
    css: |
      /* gitops default css */
    # -- (string) - logo in base64
    logo: ""
    # -- (string) - createdby.png - base64
    createdby: ""
    sponsors:
```


To do this you can follow [the example here](https://github.com/uc-cdis/data-portal/blob/master/docs/portal_config.md).

Portal can also be configured with different images and icons by updating the values, [similar to this](https://github.com/uc-cdis/cdis-manifest/tree/master/gen3.biodatacatalyst.nhlbi.nih.gov/portal). 

## Extra Information

---
# Revproxy

## What Does it Do

Revproxy is a core service to a commons which handles networking within the kuberentes cluster.

## How to Configure it

<!-- 
To configure revproxy we require an entry in the versions block. The hostname and cert arn will also need to be defined in the global block of the manifest.

```json
{
  "versions": {
    "revproxy": "version"
  },
  "global": {
    "hostname": "(commons url)",
    "revproxy_arn": "(arn of the cert from acm, within aws)"
  }
}
``` -->

## Extra Information

Revproxy is essentially an nginx container, which contains informtation about the endpoints within the cluster. There needs to be an endpoint setup for revproxy to be able to send traffic to it and start normally. Because we have many services that may or may not be setup, we only configure revproxy with the services that are deployed to a commons. The kube-setup-revproxy script will look at current deployments and add configuration files from [here](https://github.com/uc-cdis/cloud-automation/tree/master/kube/services/revproxy/gen3.nginx.conf) to the pod. So if a new service is added, you will need to run kube-setup-revproxy to setup the endpoint.

---

# Sheepdog

## What Does it Do

Sheepdog is a core service that handles data submission. Data gets submitted to the commons, using the dictionary as a schema, which is reflected within the sheepdog database.

## How to Configure it
<!-- 
To configure sheepdog we require an entry in the versions block. It also requires a dictionary in the global block.

```json
{
  "versions": {
    "sheepdog": "version"
  },
  "global": {
    "dictionary_url": "https://s3.amazonaws.com/dictionary-artifacts/(dictionary name)/(version)/schema.json"
  }
}
``` -->

## Extra Information
---
# Sower

## What Does it Do

Sower is a job dispatching service. Jobs are configured with .Values.sowerConfig and sower handles dispatching the jobs.

## How to Configure it

```yaml
sower:
  enabled: true
  sowerConfig:
    - name: pelican-export
      action: export
      container:
        name: job-task
        image: quay.io/cdis/pelican-export:master
        pull_policy: Always
        env:
        - name: DICTIONARY_URL
          valueFrom:
            configMapKeyRef:
              name: manifest-global
              key: dictionary_url
        - name: GEN3_HOSTNAME
          valueFrom:
            configMapKeyRef:
              name: manifest-global
              key: hostname
        - name: ROOT_NODE
          value: subject
        volumeMounts:
        - name: pelican-creds-volume
          readOnly: true
          mountPath: "/pelican-creds.json"
          subPath: config.json
        - name: peregrine-creds-volume
          readOnly: true
          mountPath: "/peregrine-creds.json"
          subPath: creds.json
        cpu-limit: '1'
        memory-limit: 12Gi
      volumes:
      - name: pelican-creds-volume
        secret:
          secretName: pelicanservice-g3auto
      - name: peregrine-creds-volume
        secret:
          secretName: peregrine-creds
      restart_policy: Never
    - name: pelican-export-files
      action: export-files
      container:
        name: job-task
        image: quay.io/cdis/pelican-export:master
        pull_policy: Always
        env:
        - name: DICTIONARY_URL
          valueFrom:
            configMapKeyRef:
              name: manifest-global
              key: dictionary_url
        - name: GEN3_HOSTNAME
          valueFrom:
            configMapKeyRef:
              name: manifest-global
              key: hostname
        - name: ROOT_NODE
          value: file
        - name: EXTRA_NODES
          value: ''
        volumeMounts:
        - name: pelican-creds-volume
          readOnly: true
          mountPath: "/pelican-creds.json"
          subPath: config.json
        - name: peregrine-creds-volume
          readOnly: true
          mountPath: "/peregrine-creds.json"
          subPath: creds.json
        cpu-limit: '1'
        memory-limit: 12Gi
      volumes:
      - name: pelican-creds-volume
        secret:
          secretName: pelicanservice-g3auto
      - name: peregrine-creds-volume
        secret:
          secretName: peregrine-creds
      restart_policy: Never
```

## Extra Information -->

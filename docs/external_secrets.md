# External Secrets Operator

 "External Secrets Operator" is a tool that was created by the Kubernetes community to manage external secrets in a Kubernetes cluster. It allows you to fetch and sync external secret values from various external secret management systems into Kubernetes secrets. One of the external secret management systems it can connect to is AWS Secrets Manager. Secrets Manager allows for the secure storing of your secrets as well as the ability to periodically and automatically rotate your secrets.

This document will guide you through setting up the essential resources to access your secrets in AWS Secrets Manager and download the External Secrets Operator Helm chart. This way, you can effectively utilize your stored secrets with Helm.

## Download External Secrets Operator and Create Resources in AWS.
You can use the following Bash script to apply the External Secrets Operator to your cluster and create the necessary AWS resources. Fill in the variables below to get started:

***Notice:
The Gen3 Helm chart has various jobs and uses for an Iam user. To enhance code reusability, we've implemented the option for jobs and services to share the same AWS IAM global user. If you would like to use the same Iam user for External Secrets and jobs like ["Fence Usersync"](fence_usersync_job.md) or our "AWS ES Proxy Service", you can follow [THIS](global_iam_helm_user.md) guide that details how to setup a Helm global user. In case you opt for a global IAM user, please comment out the "create_iam_policy" and "create_iam_user" functions at the end of the script.***

```
#!/bin/bash

AWS_ACCOUNT="<Your AWS Account ID>" 
region="<Desired AWS Region>"
iam_policy="<Name of the Policy to Create>"
iam_user="<Name of the User to Create>"

helm_install() 
{
    echo "# ------------------ Install external-secrets via helm --------------------------#"
    helm repo add external-secrets https://charts.external-secrets.io
    helm install external-secrets \
    external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true
}

create_iam_policy()
{
    echo "# ------------------ create iam policy for secrets manager --------------------------#"
    POLICY_ARN=$(aws iam create-policy --policy-name $iam_policy --policy-document '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "secretsmanager:ListSecrets",
                    "secretsmanager:GetSecretValue"
                ],
                "Resource": [
                    "*"
                ]
            }
        ]
    }')

    iam_policy_arn=$(aws iam list-policies --query "Policies[?PolicyName=='$iam_policy'].Arn" --output text)
    echo "Policy Arn: $iam_policy_arn"
    # return $iam_policy_arn
}

create_iam_user()
{
    echo "# ------------------ create user $iam_user --------------------------#"
    aws iam create-user --user-name $iam_user

    echo "# ------------------ add iam user $iam_user to policy $iam_policy --------------------------#"
    aws iam attach-user-policy --user-name $iam_user --policy-arn $iam_policy_arn
    echo "aws iam attach-user-policy --user-name $iam_user --policy-arn $iam_policy_arn"

    echo "# ------------------ create access key and secret key for external-secrets --------------------------#"
    aws iam create-access-key --user-name $iam_user > keys.json
    access_key=$(jq -r .AccessKey.AccessKeyId keys.json)
    secret_key=$(jq -r .AccessKey.SecretAccessKey keys.json)
    kubectl create secret generic "$iam_user"-secret --from-literal=access-key=$access_key --from-literal=secret-access-key=$secret_key
    rm keys.json
}

helm_install
#comment out the below if using global iam user.
create_iam_policy
create_iam_user
```

***Please note that Terraform for the creation and population of Gen3 Secrets in Secrets Manager is in development currently. This Terraform will also create the Iam user and policies necessary to access these secrets.***

## Enabling External Secrets in Helm charts
To enable External Secrets to be used in a helm chart, you can set the `.Values.global.externalSecrets.deploy` field to "true" for an individual chart or globally by enabling this value in the Gen3 umbrella Helm chart.

If you would like to only use External Secrets for specific charts, please ensure you set `.Values.global.externalSecrets.separate` to "true" in the appropriate charts to ensure a Secret Store can be created to authenticate with Secrets Manager.

## Helm Iam User
If you are using a separate Iam user for Secrets Manager please follow the below instructions: 

This script Bash script at the beginning of this document should have created a secret titled "NameofIAMuser-user-secret" in your cluster. You will need to retrieve these values to input into your Helm chart for the Cluster Secret Store to authenticate with Secrets Manager.


Access Key:
```
kubectl get secret "your secret name" -o jsonpath="{.data.access-key}" | base64 --decode
```


Secret Access Key
```
kubectl get secret "your secret name" -o jsonpath="{.data.secret-access-key}" | base64 --decode
```

You can paste the Iam access key and secret access key in the `.Values.secrets.awsAccessKeyId`/`.Values.secrets.awsSecretAccessKey` fields in the values.yaml file for the chart(s) you would like to use external secrets for. 

Please note that only some Helm charts are compatible with External Secrets currently. We hope to expand this functionality in the future. If a chart is able to use External Secrets, you can see a `.Values.externalSecrets` section in the values.yaml file.

## How External Secrets Works. 
External Secrets relies on three main resources to function properly. (The below have links to examples of each resource)
1. Aws-config- Contains Access and Secret Access keys used by the Cluster Secret Store to authenticate with AWS Secrets Manager
2. Cluster Secret Store- Resource to Authenticate with AWS Secrets Manager
3. External Secret- References the Secret Store and is used as a "map" to tell External Secrets Operator what secret to grab from External Secrets and the name of the Kubernetes Secret to create locally.

    Anatomy of an ExternalSecret:
    ```
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      # Name of the External Secret resource
      name: audit-g3auto
    spec:
      #How often to Sync with Secrets Manager
      refreshInterval: 5m
      secretStoreRef:
        # The name of the Cluster Secret Store to use.
        name: {{include "cluster-secret-store" .}}
        kind: ClusterSecretStore
      target:
        # What Kubernetes secret to create from the secret pulled from Secrets Manager.
        name: audit-g3auto
        creationPolicy: Owner
      dataFrom:
      - extract:
          # The name of the secret pull from Secrets Manager
          key: {{include "audit-g3auto" .}}
    ```

The External Secrets resource will usually fail with "SecretSyncedError" when it cannot find the secret name that is supplied in Secrets Manager. If this happens, the secret may still exist in Kubernetes, but it will not be overwritten by the secret value in Secrets Manager. This is helpful to know if you want to enabled the use of Secrets Manager for some, but not all the secrets in a specific Helm chart. 

## Customizing the AWS Secrets Manager Secrets Name.
When pulling a secret from secrets manager, you want to ensure that the External Secret resource is referencing the proper name of the secret in Secrets Manager.
You can customize the name of the secret to pull from in the `.Values.externalSecrets` section of a Chart. You can see the name for the confiugrable secrets in a chart by looking in this section as well. 

Any string you put in this section will override the name of the secret that is pulled from Secrets Manager NOT the name of the Kubernetes secret that is created from the External Secret resource.

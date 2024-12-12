# External Secrets Operator

 "External Secrets Operator" is a tool that was created by the Kubernetes community to manage external secrets in a Kubernetes cluster. It allows you to fetch and sync external secret values from various external secret management systems into Kubernetes secrets. One of the external secret management systems it can connect to is AWS Secrets Manager. AWS Secrets Manager allows for the secure storing of your secrets as well as the ability to periodically and automatically rotate your secrets.

This document will guide you through setting up the essential resources to access your secrets in AWS Secrets Manager and download the External Secrets Operator Helm chart. This way, you can effectively utilize your stored secrets with Helm.

## Download External Secrets Operator and Create Resources in AWS.
You can use the following Bash script to apply the External Secrets Operator to your cluster and create the necessary AWS resources. Fill in the variables below to get started:

***Notice:
The Gen3 Helm chart has various jobs and uses for an IAM user. To enhance code reusability, we've implemented the option for jobs and services to share the same AWS IAM global user. If you would like to use the same IAM user for External Secrets and jobs like ["Fence Usersync"](fence_usersync_job.md) or our "AWS ES Proxy Service", you can follow [THIS](global_IAM_helm_user.md) guide that details how to setup a Helm global user. In case you opt for a global IAM user, please comment out the "create_iam_policy" and "create_iam_user" functions at the end of the script.***

```
#!/bin/bash

AWS_ACCOUNT="<Your AWS Account ID>" 
region="us-east-1"
iam_policy="external_secrets_policy"
iam_user="external_secrets_user"

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
    echo "# ------------------ create iam policy for aws secrets manager --------------------------#"
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

***Please note that Terraform for the creation and population of Gen3 Secrets in AWS Secrets Manager is in development currently. This Terraform will also create the Iam user and policies necessary to access these secrets.***

## Enabling External Secrets in Helm charts
Our Helm architecture includes a comprehensive [umbrella](https://github.com/uc-cdis/gen3-helm/tree/master/helm/gen) chart designed to streamline the deployment of external secrets across both the umbrella chart itself and its associated subcharts. By configuring the `.Values.global.externalSecrets.deploy` setting within this umbrella chart, users can effortlessly initiate the deployment of all related external secret resources. This includes the external secret resources within the subcharts and the secret store required for their management.

#### Global Deployment of External Secrets
Upon deployment of the umbrella chart, the `.Values.global.externalSecrets.deploy` setting automatically provisions external secret resources for every subchart. This occurs regardless of the individual external secrets deployment settings within subcharts, even if they are explicitly set to `false`. This feature ensures a unified approach to secret management across all components of the architecture.

#### Selective Secret Management
For users requiring a more selective application of external secrets — targeting specific secrets while excluding others — the system is designed to accommodate such scenarios with ease.

External secret resources will only attempt to replace Kubernetes secrets when a corresponding secret is successfully located within the Secrets Manager. In instances where a specific secret is not found, the External Secrets resource will indicate a `SecretSyncedError`, signaling the absence of the targeted resource within the Secrets Manager. This error is acceptable and helpful for users who want to enable the use of AWS Secrets Manager for some, but not all the secrets in a specific Helm chart.

However, if you wish to utilize External Secrets for managing non-database secrets while still automating the creation of your database secrets, you can configure this behavior explicitly. Set `.Values.global.externalSecrets.dbCreate` to true alongside `.Values.global.postgres.dbCreate` or `.Values.postgres.dbCreate` to initiate the database creation job. This configuration will result in the creation of the necessary databases with their credentials stored securely within Kubernetes Secrets. Subsequently, you also choose to create Secrets in Secrets manager with the values that were generated from the dbCreate job if you wish to store these credentials long term.

By default, the following services will not create the Helm internal secrets when Secrets Manager is enabled: 
- Audit
- Fence
- Indexd
- Manifestservice
- Metadata

This is because CD tools like Argocd will have trouble syncing resources if the K8s secret was generated via Helm and External Secrets continues to override it. You can configure Helm to still create these secrets with External Secrets enabled by setting the appropriate variable to true. 

For example, to ensure the "audit-g3auto" secret is still created by Helm, you would need to set the following in your values.yaml file: 
```
audit: 
    # -- (map) External Secrets settings.
    externalSecrets:
    # -- (string) Will create the Helm "audit-g3auto" secret even if Secrets Manager is enabled. This is helpful if you are wanting to use External Secrets for some, but not all secrets.
    createK8sAuditSecret: true
```

#### Independent Subchart Deployment
In scenarios where subcharts are deployed independently, outside the scope of the umbrella chart, it is crucial to set the `.Values.global.externalSecrets.deploy` directive within the `values.yaml` file for each specific service.

Additionally, to facilitate the creation of a Secret Store capable of authenticating with AWS Secrets Manager, the `.Values.global.externalSecrets.separateSecretStore` should be set to true in the relevant charts. This configuration is essential for establishing proper authentication mechanisms for secret retrieval.

#### Configuring Separate Secret Stores
The `.Values.global.externalSecrets.separateSecretStore` setting can also be applied within the context of the umbrella chart deployment. Utilizing this setting allows for the creation of distinct Secret Stores dedicated to individual services. This approach is particularly beneficial for environments where it is preferable to limit access to Secrets Manager, ensuring that services only have access to the secrets explicitly required for their operation.

## Helm IAM User
If you are using a separate IAM user for AWS Secrets Manager please follow the below instructions: 

This script Bash script at the beginning of this document should have created a secret titled "NameofIAMuser-user-secret" in your cluster. You will need to retrieve these values to input into your Helm chart for the Secret Store to authenticate with AWS Secrets Manager.


Access Key:
```
kubectl get secret "your secret name" -o jsonpath="{.data.access-key}" | base64 --decode
```


Secret Access Key:
```
kubectl get secret "your secret name" -o jsonpath="{.data.secret-access-key}" | base64 --decode
```

You can paste the IAM access key and secret access key in the `.Values.secrets.awsAccessKeyId`/`.Values.secrets.awsSecretAccessKey` fields in the values.yaml file for the chart(s) you would like to use external secrets for. 

If you are deploying external secrets with the Gen3 umbrella chart, you can utilize a local secret to avoid pasting credentials in the values.yaml file. Just set `.global.aws.useLocalSecret.enabled` to true and supply your secret name.

Please note that only some Helm charts are compatible with External Secrets currently. We hope to expand this functionality in the future. If a chart is able to use External Secrets, you can see a `.Values.externalSecrets` section in the values.yaml file.

## How External Secrets Works. 
External Secrets relies on three main resources to function properly. (The below have links to examples of each resource)
1. [Aws-config](https://github.com/uc-cdis/gen3-helm/blob/master/helm/common/templates/_aws_config.tpl)- Contains Access and Secret Access keys used by the Cluster Secret Store to authenticate with AWS Secrets Manager
2. [Secret Store](https://github.com/uc-cdis/gen3-helm/blob/master/helm/common/templates/_external_secrets.tpl#L41-L62)- Resource to Authenticate with AWS Secrets Manager
3. [External Secret](https://github.com/uc-cdis/gen3-helm/blob/master/helm/common/templates/_external_secrets.tpl#L15-L38)- References the Secret Store and is used as a "map" to tell External Secrets Operator what secret to grab from External Secrets and the name of the Kubernetes Secret to create locally.

    Anatomy of an ExternalSecret:
    ```
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      # Name of the External Secret resource
      name: audit-g3auto
    spec:
      #How often to Sync with AWS Secrets Manager
      refreshInterval: 5m
      secretStoreRef:
        # The name of the Secret Store to use.
        name: {{include "cluster-secret-store" .}}
        kind: SecretStore
      target:
        # What Kubernetes secret to create from the secret pulled from AWS Secrets Manager.
        name: audit-g3auto
        creationPolicy: Owner
      data:
      # the key inside the new Kubernetes secret
      - secretKey: audit-service-config.yaml
          remoteRef:
          #name of secret in AWS Secrets Manager
          key: {{include "audit-g3auto" .}}
    ```

## Customizing the AWS Secrets Manager Secrets Name.
When pulling a secret from AWS Secrets Manager, you want to ensure that the External Secret resource is referencing the proper name of the secret in AWS Secrets Manager.
You can customize the name of the secret to pull from in the `.Values.externalSecrets` section of a Chart. You can see the name for the confiugrable secrets in a chart by looking in this section as well. 

Any string you put in this section will override the name of the secret that is pulled from AWS Secrets Manager NOT the name of the Kubernetes secret that is created from the External Secret resource.

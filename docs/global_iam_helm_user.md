# AWS IAM Global User

For Helm code reusability, we have added the functionality to use one IAM user for various jobs/services.

We are currently in the process of integrating this user into our Terraform code. In the meantime, you can manually create a global user by referring to this guide.

## What this user can do in Helm
- Fence Usersync Job
- ES Index Restore
- Restore PGdump
- External Secrets
- AWS ES Proxy Service



Example policy containing all the proper permissions:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::$BUCKET/$ENVIRONMENT/*",  
                # Fence Usersync Job: Name of the userYamlS3Path containing the user.yaml file
                "arn:aws:s3:::$BUCKET/$ENVIRONMENT/$VERSION/elasticsearch/*",  
                # ES Index Restore Job: Name of the dbRestoreBucket with the proper path to the ES dump files.
                "arn:aws:s3:::$BUCKET/$ENVIRONMENT/$VERSION/pgdumps/*"  
                # DB PG Dump Restore Job: Name of the dbRestoreBucket with the proper path to the SQL dump files.
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecrets",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "*" 
                # External Secrets: Leave as is to allow External Secrets access to your secrets in Secrets Manager.
            ]
        },
        {
            "Effect": "Allow",
            "Action": "es:*",
            "Resource": "arn:aws:es:REGION:ACCOUNT_ID:domain/CLUSTER_NAME/*" 
            # AWS ES Proxy Service: Arn of your Elasticsearch Cluster in AWS.
        }
    ]
}
```

## After Creating the User
In order to integrate the user in Helm, paste in the values of your Access and Secret Access key in `.Values.global.aws.awsAccessKeyId` and `.Values.global.aws.awsSecretAccessKey`
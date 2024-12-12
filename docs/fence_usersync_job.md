# Fence Usersync CronJob

If `.Values.usersync.usersync` is set to true, the Fence usersync-cron.yaml will be deployed to the cluster, otherwise useryaml job will be deployed instead of usersync.

User lists can be synced from three sources:

1. A ftp/sftp server that hosts user csv files that follows the format provided by dbgap, enabled if `.Values.usersync.syncFromDbgap` is set to "true". Please follow the [Sftp Setup](#sftp-setup) guide before enabling this option.

2. A user.yaml file that is pulled from the S3 bucket specified in the `.Values.usersync.userYamlS3Path` field is used to update fence's user-access database. Please note an IAM policy with S3 read is required for this option. Please follow [S3 user.yaml Setup](#s3-setup) guide below.

3. If the `.Values.usersync.userYamlS3Path` string is set to "none", the user.yaml file specified in the fence values.yaml [HERE](https://github.com/uc-cdis/gen3-helm/blob/c7b8959cdf5f7756b29c33ff330923e95981827c/helm/fence/values.yaml#L449-L1319) will be used.
 


# S3 user.yaml Setup {#s3-setup}
Please see [this](https://github.com/uc-cdis/fence/blob/master/docs/additional_documentation/user.yaml_guide.md) documentation that details user.yaml formatting.

You can pull this file from an S3 bucket that is set in the `.Values.usersync.userYamlS3Path` field. Then input the IAM credentials for a user that has read access to the specified S3 bucket in the `.Values.secrets.awsAccessKeyId` and `.Values.secrets.awsSecretAccessKey` fields. 

You can utilize a local secret to avoid pasting credentials in the values.yaml file. Just set `.global.aws.useLocalSecret.enabled` to true and supply your secret name.

***Notice:
The Gen3 Helm chart has various jobs and uses for an IAM user. To enhance code reusability, we've implemented the option for jobs and services to share the same AWS IAM global user. If you would like to use the same IAM user for Fence Usersync, External Secrets, etc.- you can follow [THIS guide that details how to setup a Helm global user](global_iam_helm_user.md).***

As previously mentioned, if the `.Values.usersync.userYamlS3Path` string is set to "none", the user.yaml file from Fence values.yaml will be used. 
 


# Dbgap
## Sftp Setup {#sftp-setup}
You can configure one or more dbGaP SFTP servers to sync telemetry files from. To configure one single dbGaP server, add credentials and information to the fence-config.yaml under dbGaP, [this is outlined here](https://github.com/uc-cdis/gen3-helm/blob/c7b8959cdf5f7756b29c33ff330923e95981827c/helm/fence/values.yaml#L1796).

To configure additional dbGaP servers, include in the config.yaml a list of dbGaP servers under dbGaP, like so:

```
dbGaP:
- info:
    host:
    username:
    password:
    ...
  protocol: 'sftp'
  ...
  ...
- info:
    host:
    username:
    ...
````

You can find more detailed information on the setup with examples [here](https://github.com/uc-cdis/fence/blob/master/docs/additional_documentation/usersync.md).

For an example of a dbGap auth file (csv), please see [this](https://github.com/uc-cdis/fence/blob/master/docs/additional_documentation/usersync.md#example-of-dbgap-authorization-file-csv-format) example for formatting. 

## Dbgap Options
 Set `.Values.usersync.addDbgap` to "true" to attempt a dbgap sync and fall back on user.yaml.

 Set `.Values.usersync.onlyDbgap` to "true" to run only a dbgap sync and ignore the user.yaml. 

## Slack Options
  Set `.Values.usersync.slack_webhook` to configure a webhook endpoint to be used for regular usersync updates to Slack.

  Set `.Values.usersync.slack_send_dbgap` to "true" to echo the files that are being seen on dbgap ftp to Slack.
 


## Other Customizations
  The `.Values.usersync.schedule` option can be set to customize the cron schedule expression. The default setting is to have the job run once every 30 minutes. 

  The `.Values.usersync.custom_image` can be set to override the default "awshelper" image for the init container of the userync cronjob.



## Specifying S3 Data to be copied to Etl-pod for Elastic Indexing
Specify new data to be copied by changing helm/etl-pod/values.yaml:L8-9 then uninstall the etl deployment with:

```
helm uninstall etl-pod 
```

Then deploy just the etl-pod with:
```
helm install etl-pod  ./helm/etl-pod -f ./helm/etl-pod/values.yaml
```

The S3_BUCKET and S3_PATH variables are string templating the following command:

```
aws s3 cp s3://$S3_BUCKET/$S3_PATH
```

where S3_BUCKET is the name of the bucket that you want
and S3_PATH is the remainder of the path to be coped from the bucket 
into the ETL pod

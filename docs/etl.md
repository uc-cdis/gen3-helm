# ETL 

The Gen3 Tube ETL is designed to translate data from a graph data model, stored in a PostgreSQL database, to indexed documents in ElasticSearch (ES), which supports efficient ways to query data from the front-end. The purpose of the Gen3 Tube ETL is to create indexed documents to reduce the response time of requests to query data. It is configured through an etlMapping.yaml configuration file, which describes which tables and fields to ETL to ElasticSearch.


You can configure the ETL like this: 

```yaml
etl:
  enabled: true
  esEndpoint: ""
  etlMapping:
    <your etl mapping here>
```

To kick off etl job run this command: 

```bash
kubectl create job --from=cronjob/etl-cronjob etl
```

If you already have a job called etl run the following. This will delete the old job and create a new instance.

```bash
kubectl delete job etl
kubectl create job --from=cronjob/etl-cronjob etl
```

For more information about our ETL read [here github.com/uc-cdis/tube](https://github.com/uc-cdis/tube)
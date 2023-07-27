# Building the ETL Docker Image

## 1. Authenticate with quay.io
```sh
docker login quay.io
# Login Succeeded
```

## 2. Build the image
```sh
docker build -t quay.io/ohsu-comp-bio/aced-etl .
```

## 3. Push to the quay.io repository
```sh
docker push quay.io/ohsu-comp-bio/aced-etl
```

## ETL image file structure

The `data_model` directory contains the ETL scripts and latest `aced.md` schema required to upload data to the Gen3 endpoint.

```
/data_model
├── DATA
├── README.md
├── aced.json
├── anonymizer
├── coherent_studies.manifest.yaml
├── config.yaml
├── data_model.md
├── docs
├── gen3.config.yaml
├── generated-json-schema
├── output -> /output
├── requirements-dev.txt
├── requirements.txt
├── scripts
├── static_gen3_fixtures
├── studies -> /studies
├── tests
├── utils
└── venv
```

The `creds` directory contains all credential files required for the ETL process.

```
/creds
├── credentials.json
├── sheepdog-creds
│   ├── database -> ..data/database
│   ├── dbcreated -> ..data/dbcreated
│   ├── host -> ..data/host
│   ├── password -> ..data/password
│   ├── port -> ..data/port
│   └── username -> ..data/username
└── user.yaml
```
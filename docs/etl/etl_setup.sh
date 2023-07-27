#!/bin/bash
# Script to setup environment for the ACED ETL process

# Install network and development tools. gcc is necessary for installing the gen3 SDK.
apt-get -y update
apt-get -y --no-install-recommends install  \
           build-essential \
           curl \
           gcc \
           git \
           iputils-ping \
           libpq-dev \
           python3-dev \
           unzip \
           vim
rm -rf /var/lib/apt/lists/* \

git clone https://github.com/ACED-IDP/data_model
cd data_model
python3 -m venv venv
source venv/bin/activate
pip install --no-cache-dir -r requirements.txt
# mac silicon, build from scratch, avoids Postgresql SCRAM authentication problem
pip install --no-cache-dir psycopg2

# Fetch the latest schema
curl https://aced-public.s3.us-west-2.amazonaws.com/aced.json > /aced.json

#!/bin/bash

source ../.env

pcdc clear_elasticsearch

cd ./gen3_etl/elasticsearch

# Check if the 'env' directory exists
if [ ! -d "env" ]; then
    # If 'env' directory doesn't exist, create a virtual environment
    echo "Creating virtual environment..."
    python -m venv env
else
    echo "Virtual environment 'env' already exists."
fi

# Activate the virtual environment
source env/bin/activate

poetry install

curr_dir=$(pwd)
auth_file_path="$curr_dir/env/lib/python3.9/site-packages/gen3/auth.py"
submission_file_path="$curr_dir/env/lib/python3.9/site-packages/gen3/submission.py"

if [ ! -f "$auth_file_path" ]; then
    echo "Error: File not found: $auth_file_path"
    exit 1
fi

if [ ! -f "$submission_file_path" ]; then
    echo "Error: File not found: $submission_file_path"
    exit 1
fi
# Find the line number where the text to be replaced is located
line_number=$(grep -n "resp = requests.post(auth_url, json=api_key)" "$auth_file_path" | cut -d ":" -f 1)

# Edit the specified line
sed -i "" "${line_number}s/resp = requests.post(auth_url, json=api_key)/resp = requests.post(auth_url, json=api_key, verify=False)/" "$auth_file_path"
 
echo "AUTH file edited successfully."

sed -i "" -E 's/(requests\..*)\)/\1, verify=False)/' "$submission_file_path"

echo "submission file edited successfully."

mkdir -p files

cd etl

python etl.py et


python etl.py l

cd ../../../..

INDEX=$(grep 'INDEX_NAME' .env | cut -d '=' -f 2-)
INDEX=$(echo "$INDEX" | sed "s/'//g")


cat << EOF > temp.yaml
guppy:
  indices:
    - index: "$INDEX" 
      type: "subject"
  configIndex: "$INDEX-array-config"
  authFilterField: "auth_resource_path"
EOF

yq eval '. * load("./temp.yaml")' secret-values.yaml > updated-secret-values.yaml && mv updated-secret-values.yaml secret-values.yaml


pcdc roll revproxy guppy pcdcanalysistools


rm ./temp.yaml
#!/bin/bash

# Define the file path
generate_file="./gen3_etl/graph/generate.sh"

# Check if the file exists
if [ ! -f "$generate_file" ]; then
    echo "Error: $generate_file not found."
    exit 1
fi

chmod +x "$generate_file"

# Use sed to replace the line
sed -i '' 's/GEN3_SCRIPTS_REPO_BRANCH="origin\/pcdc_dev"/GEN3_SCRIPTS_REPO_BRANCH="origin\/pyyaml-patch"/' "$generate_file"

echo "data-simulator branch changed to pyyaml-patch change when PR is completed"

# Run the generate_file script
cd ./gen3_etl/graph
mkdir ./fake_data
./generate.sh

# run our update script
SUBJECT_JSON="./fake_data/data-simulator/subject.json"
EXTERNAL_JSON="../../external/external_reference.json"
UPDATE_SCRIPT="../../external/update_external_references.py"

# Grab a version of the external_reference, as well as the subject, and connect them together via submitter_id
python3 "$UPDATE_SCRIPT" "$SUBJECT_JSON" "$EXTERNAL_JSON"

# copy our external_refernce.json to where it belongs
cp ../../external/external_reference.json ./fake_data/data-simulator/

cd ../../
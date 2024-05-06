#!/bin/bash

# Define the file path
generate_file="generate.sh"

cd ./gen3_scripts/gen3_load

# Check if the file exists
if [ ! -f "$generate_file" ]; then
    echo "Error: $generate_file not found."
    exit 1
fi

chmod +x ./generate.sh

# Use sed to replace the line
sed -i '' 's/GEN3_SCRIPTS_REPO_BRANCH="origin\/pcdc_dev"/GEN3_SCRIPTS_REPO_BRANCH="origin\/pyyaml-patch"/' "$generate_file"

echo "data-simulator branch changed to pyyaml-patch change when PR is completed"

./generate.sh

cd ../..
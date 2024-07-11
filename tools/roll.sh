#!/bin/bash

# Change directory to the helm chart directory
cd "$(dirname "$0")/../helm/gen3" || exit 1 || exit 1

rm ../../values.yaml

project="$1"
shift
# Check if ../../secret-values.yaml exists
if [ -f ../../secret-values.yaml ]; then
  yq '. *= load("../../secret-values.yaml")' ../../$project-default-values.yaml > ../../values.yaml
else 
  cp ../../$project-default-values.yaml ../../values.yaml
fi
# Directory to store CA certificate
ca_dir=../../CA
ca_file=$ca_dir/ca.pem

# Create the CA certificate directory if it doesn't exist
if [ ! -d "$ca_dir" ]; then
    mkdir -p "$ca_dir"
fi

# Check if CA certificate file exists, if not, create it
if [ ! -f "$ca_file" ]; then
    # Create the CA certificate file
    echo "Creating CA certificate file..."
    touch "$ca_file"
fi

# Extract the value from ../../values.yaml
ca_cert=$(yq eval '.global.tls.cert' ../../values.yaml)

# Write the extracted value to the CA certificate file
echo "$ca_cert" > "$ca_file"

# Check if arguments are passed
if [ $# -gt 0 ]; then
  # Iterate over each argument (service name)
  for service_name in "$@"
  do
    # Delete the deployment corresponding to the service name
    kubectl delete deployment ${service_name}-deployment
    if [ "$service_name" = "gearbox" ]; then
      kubectl delete job gearbox-g3auto-patch
    fi

  done
fi

# Run helm dependency update
helm dependency update

# Run helm upgrade --install command
helm upgrade --install $project . -f ../../values.yaml
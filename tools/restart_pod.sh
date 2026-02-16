#!/bin/bash

# Check if service name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

service_name=$1

# Get pod name associated with the service
pod_name=$(kubectl get pods -l app="$service_name" -o jsonpath='{.items[*].metadata.name}')

# Check if pod name is empty
if [ -z "$pod_name" ]; then
    echo "Error: No pod found for service $service_name"
    exit 1
fi

# Execute delete pod
kubectl delete pod "$pod_name"
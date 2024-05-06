#!/bin/bash

# Check if service name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 [-f] <service_name>"
    exit 1
fi

# Check if the first argument is "-f"
if [ "$1" = "-f" ]; then
    follow_logs=true
    shift  # Remove the "-f" argument from the argument list
else
    follow_logs=false
fi

service_name=$1

# Get pod name associated with the service
pod_name=$(kubectl get pods -l app="$service_name" -o jsonpath='{.items[*].metadata.name}')

# Check if pod name is empty
if [ -z "$pod_name" ]; then
    echo "Error: No pod found for service $service_name"
    exit 1
fi

# Execute kubectl logs with or without "-f" option based on the flag
if [ "$follow_logs" = true ]; then
    kubectl logs -f "$pod_name"
else
    kubectl logs "$pod_name"
fi
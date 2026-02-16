#!/bin/bash

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <job_name>"
    exit 1
fi

# Extract the job name
project="$1"
job_name="$2"

# Delete the specified Job
kubectl delete job "$job_name"

# Check if the deletion was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to delete Job $job_name"
    exit 1
fi

# Run roll.sh script
$project roll 
#!/bin/bash

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <job_name>"
    exit 1
fi

# Extract the job name
job_name="$1"

# Delete the specified Job
kubectl delete job "$job_name"

# Check if the deletion was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to delete Job $job_name"
    exit 1
fi

# Run roll.sh script
roll.sh
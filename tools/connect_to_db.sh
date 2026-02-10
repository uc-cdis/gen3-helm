#!/bin/bash

# Check if service name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

project_name=$1
service_name=$2

# Retrieve password from secret
password=$(kubectl get secret ${service_name}-dbcreds -o jsonpath="{.data.password}" | base64 --decode)

# Execute command in the pod
kubectl exec -it ${project_name}-postgresql-0 -- /bin/bash -c "PGPASSWORD='${password}' psql -h ${project_name}-postgresql -U ${service_name}_${project_name} -d ${service_name}_${project_name}"
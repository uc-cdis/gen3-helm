#!/bin/bash

# Check if service name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <service_name>"
    exit 1
fi

service_name=$1

# Retrieve password from secret
password=$(kubectl get secret ${service_name}-dbcreds -o jsonpath="{.data.password}" | base64 --decode)

# Execute command in the pod
kubectl exec -it pcdc-postgresql-0 -- /bin/bash -c "PGPASSWORD='${password}' psql -h pcdc-postgresql -U ${service_name}_pcdc -d ${service_name}_pcdc"
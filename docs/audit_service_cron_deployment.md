## Audit Service Deployment Instructions
Audit service export cronjob expects the following steps to be performed before deployment. 
1. **Fence client creation**
   A new Fence client named `audit-export-client` must exist. Be sure to save the `(CLIENT_ID, CLIENT_SECRET)` for next steps.

   ```bash
   # Exec into the Fence K8s pod and run:
   fence-create client-create --client audit-export-client --grant-types client_credentials
   ```

2. **User YAML update**
   The corresponding user YAML must assign the `sower` policy to this client. Be sure to run `usersync` after updating.

   ```yaml
   clients:
     audit-export-client:
       policies:
         - sower
   ```

3. **Kubernetes secret**
   A K8s secret named `audit-export-oidc-client` must store the client\_id and client\_secret for the Fence client.

   ```bash
   # Run this in the target environment
   CLIENT_ID=<redacted>
   CLIENT_SECRET=<redacted>

   # Create secret (first time only)
   kubectl create secret generic audit-export-oidc-client \
     --from-literal=client_id="${CLIENT_ID}" \
     --from-literal=client_secret="${CLIENT_SECRET}" \
     -n qa-midrc-test | kubectl apply -f -

   # Patch secret if it already exists
   kubectl patch secret/audit-export-oidc-client \
     --patch="{\"data\":{\"client_secret\":\"$(echo -n $CLIENT_SECRET | base64)\", \"client_id\":\"$(echo -n $CLIENT_ID | base64)\"}}" \
     -n qa-midrc-test
   ```

---

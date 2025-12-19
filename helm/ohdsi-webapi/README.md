# Steps to test this WebAPI chart locally

1. Adjust `webapiConfig` DB connection settings in `values.yaml`
2. Set `webapiSecretsServiceAccountName` to "default" in `values.yaml`
3. Add a "fence-config" secret based on your local Fence config yaml:
```
kubectl create secret generic fence-config \
  --from-file=fence-config.yaml
```
e.g. 
```
kubectl create secret generic fence-config \
  --from-file=/Users/plukasse/dev/fence/fence-config.yaml
```
This will ensure your WebAPI is registered as a client
in this Fence instance, and the Fence clientID and client secret
are passed back into the respective WebAPI config items.

4. Add the "fence-dbcreds" secret (used by job in step 6 below):

```
kubectl create secret generic fence-dbcreds \
  --from-literal=host=your-db-host.example.com \
  --from-literal=username=your_db_user \
  --from-literal=password=your_db_password \
  --from-literal=database=your_db_name \
  --from-literal=port=your_db_port

```
example:
```
kubectl create secret generic fence-dbcreds \
  --from-literal=host=host.docker.internal \
  --from-literal=username=postgres \
  --from-literal=password=mysecretpassword \
  --from-literal=database=fence_test \
  --from-literal=port=":5433"
```
where `port=":<port number>"` is only needed if using non-standard port.

5. Install chart with:
```
helm install my-release-name . 
```
6. Monitor the most complex step (creating a Fence client for WebAPI) with:
```
kubectl describe pod atlas-webapi-client-job-<SOME_UID>

and each job step with:

kubectl logs -f atlas-webapi-client-job-<SOME_UID> -c wait-for-fence
kubectl logs -f atlas-webapi-client-job-<SOME_UID> -c add-fence-client
kubectl logs -f atlas-webapi-client-job-<SOME_UID> -c update-webapi-config
```

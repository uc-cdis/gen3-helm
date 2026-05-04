# Steps to test this WebAPI chart locally

1. Adjust `webapiConfig` DB connection settings in `values.yaml`
2. Add a "fence-config" secret based on your local Fence config yaml:
```
kubectl create secret generic fence-config \
  --from-file=fence-config.yaml
```
e.g. 
```
kubectl create secret generic fence-config \
  --from-file=/Users/myuser/dev/fence/fence-config.yaml
```
This will ensure your WebAPI is registered as a client
in this Fence instance, and the Fence clientID and client secret
are passed back into the respective WebAPI config items.

3. Install chart with:
```
helm uninstall my-release-name
helm install my-release-name . 
```
OR for testing locally:
```
helm uninstall my-release-name
helm install my-release-name . --values ./values_local.yaml
```

4. Monitor the most complex step (creating a Fence client for WebAPI) with:
```
kubectl describe job ohdsi-webapi-client-job

and then

kubectl describe pod ohdsi-webapi-client-job-<SOME_UID>

and each job step with:

kubectl logs -f ohdsi-webapi-client-job-<SOME_UID> -c wait-for-fence
kubectl logs -f ohdsi-webapi-client-job-<SOME_UID> -c add-fence-client
kubectl logs -f ohdsi-webapi-client-job-<SOME_UID> -c update-webapi-config
```
5. Forward internal port 80 to 8888:
```
kubectl port-forward svc/ohdsi-webapi-service 8888:80
```
6. Check result in browser:
http://localhost:8888
http://localhost:8888/WebAPI/user/login/openid?redirectUrl=/home
or add a team project:
http://localhost:8888/WebAPI/user/login/openid?redirectUrl=/home?teamproject=team1

Other URLs that can be checked to ensure
DB connection is working:
http://localhost:8888/WebAPI/conceptset
or 
http://atlas.localhost:8888/WebAPI/conceptset
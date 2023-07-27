# Enabling internal HTTPS connections with revproxy

## 1) Copy SSL certs

For this example we are using the `service.crt` and `service.key` files for https://aced-training.compbio.ohsu.edu and copying them to the `ssl` directory in the `revproxy` helm chart --

```sh
cp service.* helm/revproxy/ssl
```

## 2) Update Helm

Update the `revproxy` helm chart and deploy from the now updated local helm repo --

```sh
helm dependency update helm/gen3
helm upgrade --install local ./helm/gen3 -f values.yaml -f fence-config.yaml -f user.yaml
```

## 3) Verify connection

Verify that the `revproxy` target is reachable from the ETL pod by `curl`-ing the hostname (we should see the large HTMl response) -- 

```sh
kubectl exec --stdin --tty etl -- /bin/bash
root@etl:/# curl https://aced-training.compbio.ohsu.edu
<!doctype html><html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta http-equiv="Content-Security-Policy" content="default-src 'self' https://login.bionimbus.org ...
```

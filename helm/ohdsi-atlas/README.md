# Steps to test this Atlas chart locally

1. Start a WebAPI backend (see also ../ohdsi-webapi for a WebAPI helm chart)
3. Install this Atlas chart with:
```
helm install my-atlas-release . 
```
OR for developing and testing locally:
```
helm install my-atlas-release . --values ./values_local.yaml
```
4. Forward internal port 80 to 8889:
kubectl port-forward svc/ohdsi-atlas-service 8889:80


5. Browse to http://localhost:8889/atlas/

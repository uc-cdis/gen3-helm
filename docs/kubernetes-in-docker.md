# Gen3 in KIND
## Kind (Kubernetes IN Docker)

### Overview
KIND runs Kubernetes inside a Docker container, making it an excellent choice for local development and testing. It is also used by the Kubernetes team to test Kubernetes itself.

### Pros:

Fast cluster creation (around 20 seconds).
Robust and reliable, thanks to containerd usage.
Suitable for CI environments (e.g., TravisCI, CircleCI).

### Cons:

Ingress controllers needs to be deployed manually




# Step 1. Create cluster

```bash
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```

https://kind.sigs.k8s.io/docs/user/ingress/ 

# Step 2: deploy ingress

https://kind.sigs.k8s.io/docs/user/ingress/

We are going to deploy nginx-ingress like this:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

Now the Ingress is all setup. Wait until is ready to process requests running:

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Deploy gen3

## Google login 
You need to set up a google credential for google login as that’s the default enabled option in fence.

The following steps explain how to create credentials for your gen3

Go to the Credentials page. https://console.developers.google.com/apis/credentials

Click Create credentials > OAuth client ID.

Select the Web application application type. Name your OAuth 2.0 client and click Create.

For Authorized Javascript Origins add https://<hostname>

For "Authorized redirect URIs" add https://<hostname>/user/login/google/login/

After configuration is complete, take note of the client ID that was created. You will need the client ID and client secret to complete the next steps.

## Prepare values.yaml

Create a file called values.yaml and populate it like this (This is the main way of configuring gen3. this is just some default values that will help you get started)

```yaml
global:
  # This can be anything you want! 
  hostname: dev.planx-pla.net

fence: 
  FENCE_CONFIG:
    OPENID_CONNECT:
      google:
        client_id: "<from previous step>"
        client_secret: "<from previous step>"

# Use a prebuilt portal image if you're deploying to a laptop, less resources consumed by gen3
portal:
  resources:
    requests:
      cpu: "0.2"
      memory: 100Mi
  image:
    repository: quay.io/cdis/data-portal-prebuilt
    tag: dev

```

## deploy gen3

```bash
helm repo add gen3 http://helm.gen3.org
helm upgrade --install gen3 gen3/gen3 -f ./values.yaml 
```
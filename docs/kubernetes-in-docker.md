# KIND

## LINK TO ORBSTACK ON M1

## 



# Create cluster

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

# deploy kong

```bash
kubectl apply -f https://raw.githubusercontent.com/Kong/kubernetes-ingress-controller/master/deploy/single/all-in-one-dbless.yaml
```


# Patch ingress to work with kong

```bash
kubectl patch ingress revproxy-dev -p '{"spec":{"ingressClassName":"kong"}}'
```

# Deploy gen3
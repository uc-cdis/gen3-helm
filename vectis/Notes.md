# Note on running vectis locally

Need to support linux-amd platform as these do not have images for arm64.

need to enable the following:
* Rosetta for macbook
* Kind config below

To run a hatchery pod: need to run: `kubectl label node kind-multi-node-control-plane role=jupyter`

# create api credential with scope "credentials":
```
fence-create token-create --scopes openid,user,fence,data,credentials,google_service_account,google_credentials --type access_token --exp 10800 --username craigrbarnes@uchicago.edu
```

## Kind config
```yaml
# kind config to handle running kind with linux-amd64 nodes

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name:  kind-multi-node
networking:
  ipFamily: ipv4
  apiServerAddress: 127.0.0.1
nodes:
  - role: control-plane
    extraMounts:
      - hostPath: ./coredns-custom
        containerPath: /etc/coredns/custom
    kubeadmConfigPatches:
      - |
        kind: ClusterConfiguration
        apiVersion: kubeadm.k8s.io/v1beta3
        dns:
          type: CoreDNS
          coreDNS:
            extraArgs:
              conf: /etc/coredns/custom/Corefile
      - |
        kind: InitConfiguration
        apiVersion: kubeadm.k8s.io/v1beta3
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
containerdConfigPatches:
  - |-
    [plugins."io.containerd.grpc.v1.cri"]
      disable_apparmor = true
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        SystemdCgroup = true
        DisableNewKeyring = true
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes."runc-amd64"]
      runtime_type = "io.containerd.runc.v2"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes."runc-amd64".options]
        SystemdCgroup = true
        DisableNewKeyring = true
```
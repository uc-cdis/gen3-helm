#! /bin/bash

# Script Name: gen3-bootstrap.sh

# Description of purpose:
# This script is designed to bootstrap a local development environment for gen3. 
# It will install (if not already installed) kubectl, helm, docker, kind, k9s, and then deploy and configure ingress-nginx, and gen3.
# Additional comments:
# This script is designed to be run on a Mac or Linux machine.
# This script will also update your hosts file to route your commons hostname to your computer (localhost)

# Script contents start below this line
# -------------------------------------

# exit if any command fails
# set -e

# install kubectl
function install_kubectl() {
    # check if kubectl is installed 
    if ! command -v kubectl &> /dev/null
    then
        echo "kubectl could not be found"
        echo "installing kubectl"
        # install kubectl
        # Check if uname == Darwin
        if [ $(uname) = Darwin ]
        then
            # For AMD64 / x86_64
            [ $(uname -m) = x86_64 ] && curl -Lo ./kubectl https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/darwin/amd64/kubectl
            # For ARM64
            [ $(uname -m) = aarch64 ] && curl -Lo ./kubectl https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/darwin/arm64/kubectl
            chmod +x ./kubectl
            sudo mv ./kubectl /usr/local/bin/kubectl
        fi

        # Check if uname == Linux
        if [ $(uname) = Linux ]
        then
            # For AMD64 / x86_64
            [ $(uname -m) = x86_64 ] && curl -Lo ./kubectl https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
            # For ARM64
            [ $(uname -m) = aarch64 ] && curl -Lo ./kubectl https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/arm64/kubectl
            chmod +x ./kubectl
            sudo mv ./kubectl /usr/local/bin/kubectl
        fi
    fi
}

# Function to compare versions
function version_lt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}


# install helm cli
function install_helm() {
    # check if helm is installed 
    if ! command -v helm &> /dev/null
    then
        echo "helm could not be found"
        echo "installing helm"
        # install helm
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh --version v3.12.3
        # cleanup 
        rm -rf get_helm.sh
    fi

    # Get the current Helm version
    current_helm_version=$(helm version --short | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
    
    major=$(echo $current_helm_version | cut -d'.' -f1)
    minor=$(echo $current_helm_version | cut -d'.' -f2)
    
    # if minor is greater than 12 then install 3.12 for user 
    if [ $minor -gt 12 ]; then
        echo "helm version is greater than 3.12, which includes a breaking change for gen3"
        echo "installing helm 3.12"
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh --version v3.12 --no-sudo
        # cleanup 
        rm -rf get_helm.sh
    fi

    helm version

}

# checkout gen3-helm repository
function checkout_gen3_helm() {
    # checkout gen3-helm repository 
    if [ ! -d ~/.gen3/gen3-helm ]; then
        echo "gen3-helm repository not found"
        echo "cloning gen3-helm repository"
        mkdir -p ~/.gen3
        git clone https://github.com/uc-cdis/gen3-helm.git ~/.gen3/gen3-helm
    else 
        git -C ~/.gen3/gen3-helm checkout master
        git -C ~/.gen3/gen3-helm pull
    fi
}

function gen3_helm_repo() {
    # add gen3-helm repo
    helm repo add gen3 https://helm.gen3.org
    helm repo update
}

# install docker 
function install_docker() {
    # check if docker is installed 
    if ! command -v docker &> /dev/null
    then
        echo "docker could not be found"
        echo ""

        echo "Please install a  docker runtime before re-running this script"
        echo ""
        echo "For more information on how to install docker, please visit:"
        echo "https://docs.docker.com/get-docker/"
        echo ""
        echo "Or use orbstack for M1 Macs"
        echo "https://orbstack.dev"
        echo ""
        echo ""
        echo "Or use Rancher Desktop"
        echo "https://rancherdesktop.io"
        echo ""
        exit 1
    fi

    # cleanup 
    rm -rf get-docker.sh
}

# install kind 
function install_kind() {
    # check if kind is installed 
    if ! command -v kind &> /dev/null
    then
        echo "installing kind"
        # check if mac 
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # For Intel Macs
            [ $(uname -m) = x86_64 ] && curl -sSLo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-amd64
            # For M1 / ARM Macs
            [ $(uname -m) = arm64 ] && curl -sSLo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-arm64
            chmod +x ./kind
            mv ./kind /usr/local/bin/kind
            kind version
        else
            # for linux
            # For AMD64 / x86_64
            [ $(uname -m) = x86_64 ] && curl -sSLo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
            # For ARM64
            [ $(uname -m) = aarch64 ] && curl -sSLo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-arm64
            chmod +x ./kind
            sudo mv ./kind /usr/local/bin/kind
            kind version
        fi
    fi
}

# Create kind cluster 
function create_kind_cluster() {
    # Check if cluster already exists
    if ! kind get clusters | grep -q "kind"; then
        echo "kind cluster not found"
        echo "creating Kubernetes in Docker (KIND) cluster for gen3 deployment"
        # create kind cluster with port 80 and 443 exposed
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
    else
        # make this text green
        echo "kind cluster found"
        # echo "skipping creation of Kubernetes in Docker (KIND) cluster for gen3 deployment"
        # echo ""
        # echo "TIP: If you are having issues and want to 💣 nuke💣 your cluster to start from scratch, run 'kind delete cluster' and re-run this script"
    fi
}




function apply_k8_alias() {
    # create gen3-k8s-alias file and overwrite contents with this
    # make sure ~/.gen3 folder exist
    mkdir -p ~/.gen3
    cat <<EOF > ~/.gen3/gen3-k8s-alias
# if (( $+commands[kubectl] )); then
#     __KUBECTL_COMPLETION_FILE="${ZSH_CACHE_DIR}/kubectl_completion"

#     if [[ ! -f $__KUBECTL_COMPLETION_FILE ]]; then
#         kubectl completion zsh >! $__KUBECTL_COMPLETION_FILE
#     fi

#     [[ -f $__KUBECTL_COMPLETION_FILE ]] && source $__KUBECTL_COMPLETION_FILE

#     unset __KUBECTL_COMPLETION_FILE
# fi

# This command is used a LOT both below and in daily life
alias k=kubectl

# Execute a kubectl command against all namespaces
alias kca='f(){ kubectl "$@" --all-namespaces;  unset -f f; }; f'

# Apply a YML file
alias kaf='kubectl apply -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti'

# Manage configuration quickly to switch contexts between local, dev ad staging.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'

# List all contexts
alias kcgc='kubectl config get-contexts'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'

# Pod management.
alias kgp='kubectl get pods'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'

# Service management.
alias kgs='kubectl get svc'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'
alias kcn='kubectl config set-context $(kubectl config current-context) --namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
kres(){
    kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Port forwarding
alias kpf="kubectl port-forward"

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# File copy
alias kcp='kubectl cp'

# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'
EOF
    source ~/.gen3/gen3-k8s-alias

    # adding to .zshrc or .bashrc whatever exists 
    if [ -f ~/.zshrc ]; then
        # check if gen3-k8s-alias is already in .zshrc
        # if not, add it
        if ! grep -q "gen3-k8s-alias" ~/.zshrc; then
            echo "adding gen3-k8s-alias to .zshrc"
            echo "source ~/.gen3/gen3-k8s-alias" >> ~/.zshrc
        fi
    elif [ -f ~/.bashrc ]; then
        # check if gen3-k8s-alias is already in .bashrc
        # if not, add it
        if ! grep -q "gen3-k8s-alias" ~/.bashrc; then
            echo "adding gen3-k8s-alias to .bashrc"
            echo "source ~/.gen3/gen3-k8s-alias" >> ~/.bashrc
        fi
    fi
    
}


function install_k9s() {
    # check if k9s is installed 
    if ! command -v k9s &> /dev/null
    then
            echo "installing k9s"
        # check if mac 
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # For Intel Macs
            [ $(uname -m) = x86_64 ] && curl -sSLo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.28.2/k9s_Darwin_amd64.tar.gz
            # For M1 / ARM Macs
            [ $(uname -m) = arm64 ] && curl -sSLo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.28.2/k9s_Darwin_arm64.tar.gz 
            tar -xvf k9s.tar.gz k9s
            chmod 700 ./k9s > /dev/null 2>&1
            mv ./k9s /usr/local/bin/k9s
            rm -rf k9s.tar.gz
            k9s version
        else
            # install k9s
            # For AMD64 / x86_64
            [ $(uname -m) = x86_64 ] && curl -sSLo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.28.2/k9s_Linux_amd64.tar.gz
            # # For ARM64
            [ $(uname -m) = aarch64 ] && curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.28.2/k9s_Linux_arm64.tar.gz
            tar -xvf k9s.tar.gz k9s
            chmod 700 ./k9s > /dev/null 2>&1
            mv ./k9s /usr/local/bin/k9s
            rm -rf k9s.tar.gz
            k9s version
        fi
    else 
        k9s version
    fi
}


function install_ingress() {
    # chekc if ingress-nginx is installed 
    if kubectl wait --namespace ingress-nginx  --for=condition=ready pod --selector=app.kubernetes.io/component=controller  --timeout=90s > /dev/null 2>&1; then
        return
    fi
    echo "installing ingress-nginx"

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml > /dev/null 2>&1
    sleep 15
    kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
    echo "ingress-nginx installed"
    sleep 30
}



function nuke() {
    if command -v kind &> /dev/null 2>&1;
    then
        if kind get clusters | grep -q "kind"; then
            echo "deleting kind cluster"
            kind delete cluster
        fi
    fi
    
    sudo rm -rf ~/.gen3/values.yaml  || true
    sudo rm -rf ~/.gen3/gen3-k8s-alias  || true
    sudo rm -rf ~/.gen3/gen3-helm  || true
}

function install_gen3() {
    # check if values file exists in ~/.gen3/values.yaml
    if [ ! -f ~/.gen3/values.yaml ]; then
        echo "values.yaml file not found under ~/.gen3/values.yaml"
        echo "please create a values.yaml file under ~/.gen3/values.yaml"
        exit 1
    fi

    helm dependency update ~/.gen3/gen3-helm/helm/gen3 > /dev/null 2>&1
    kubectl delete jobs --all > /dev/null 2>&1
    helm upgrade --install gen3 ~/.gen3/gen3-helm/helm/gen3 -f ~/.gen3/values.yaml
}

function update_hosts_file() {
    # get hostname from ~/.gen3/values.yaml file by grepping and taking first line only and awk to get second column
    hostname=$(cat ~/.gen3/values.yaml | grep 'hostname' | head -n 1 | awk '{print $2}')
    # check if hosts file already has the hostname added
    if grep -q "$hostname" /etc/hosts; then
        return
    fi

    # add hostname to /etc/hosts file and make it route to localhost
    echo "adding hostname $hostname to /etc/hosts for local routing"
    echo "127.0.0.1 $hostname" | sudo tee -a /etc/hosts
}

# main function
function main() {
    if [ "$1" == "-h" ]; then
        echo "Usage: ./dev-bootstrap.sh [-n] [-h]"
        echo "Options:"
        echo "  -h: help"
        echo "  --hosts: update your hosts file"
        echo "  --k9s: install k9s"
        echo "  --kubectl: install kubectl"
        echo "  --helm: install helm"
        echo "  --docker: install docker"
        echo "  --kind: install kind"
        echo "  --ingress: install ingress-nginx"
        echo "  --gen3: install gen3"
        echo "  --alias: apply k8 alias"
        echo "  --nuke | -n: nuke your local environment"
        return
    fi
    
    # nuke if -n flag is passed
    if [ "$1" == "-n" ] || [ "$1" == "--nuke" ]; then
        nuke
        return
    fi

    # update hosts file only if --host flag is passed
    if [ "$1" == "--hosts" ]; then
        update_hosts_file
        return
    fi

    # run only k9s
    if [ "$1" == "--k9s" ]; then
        install_k9s
        return
    fi

    # run only kubectl
    if [ "$1" == "--kubectl" ]; then
        install_kubectl
        return
    fi

    # run only helm
    if [ "$1" == "--helm" ]; then
        install_helm
        return
    fi

    # run only docker
    if [ "$1" == "--docker" ]; then
        install_docker
        return
    fi

    # run only kind
    if [ "$1" == "--kind" ]; then
        install_kind
        return
    fi

    # run only ingress
    if [ "$1" == "--ingress" ]; then
        install_ingress
        return
    fi

    # run only gen3
    if [ "$1" == "--gen3" ]; then
        install_gen3
        return
    fi

    # run only alias
    if [ "$1" == "--alias" ]; then
        apply_k8_alias
        return
    fi

    # check if values file exists in ~/.gen3/values.yaml
    if [ ! -f ~/.gen3/values.yaml ]; then
        echo "values.yaml file not found under ~/.gen3/values.yaml"
        echo "Please create a values.yaml file under ~/.gen3/values.yaml and re-run this script"
        echo ""
        echo "(to CTDS: There is a dev values.yaml in keeper that you can use as a template)"
        exit 1
    fi

    install_kubectl
    apply_k8_alias
    install_helm
    install_docker
    install_kind
    create_kind_cluster
    install_k9s
    checkout_gen3_helm
    install_ingress
    install_gen3
    update_hosts_file
    k9s
}

# run main function
main $@

default:
    @just --list

arch := arch()
local_arch := if arch() == "aarch64" { "arm64" } else { "amd64" }

host_aware_act *args:
    act --container-architecture="{{ local_arch }}" {{ args }}

alias a := host_aware_act

lint_workflow:
    @just a --dryrun

# run after tilt up
helm_update:
    helm dependency update .

make_lab:
    # Earthly populate registry
    kind create cluster --config ./wip/kind-config.yaml --name lab
    kubectl create namespace lab

unmake_lab:
    kind delete clusters lab

# up and down are good
tilt_up:
    tilt up --legacy --

tilt_down:
    tilt down

everclone *arg:
    git clone git@github.com:uc-cdis/{{ arg }}.git deps/{{ arg }} || true

# Buildthemall
all:
    mkdir -p deps
    @just everclone base-images
    @just everclone cloud-automation
    @just everclone docker-bitnami-pgvector
    @just everclone fence
    @just everclone gen3-code-vigil
    @just everclone gen3-helm
    earthly build +all

# Terragrunt supports this betterish
bin:
    arkade get terraform
    # arkade get tofu

# eBPF neeato cilium
net:
    # TODO: rip kube-proxy out
    arkade get cilium hubble crossplane

# get linters and vcluster
arkade:
    arkade get vcluster tflint terragrunt tilt

# Installs arkade and earthly, bootstraps earthly and spits out docker ps
brew:
    brew install arkade earthly
    earthly bootstrap
    docker ps

install_tilt:
    VERSION="0.37.4" ./.tiltinstall.sh


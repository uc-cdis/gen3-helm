# just --list
default:
    @just --list

arch := arch()
local_arch := if arch() == "aarch64" { "arm64" } else { "amd64" }

host_aware_act *args:
    act --container-architecture="{{ local_arch }}" {{ args }}

alias a := host_aware_act

lint_workflow:
    @just a --dryrun

# Buildthemall
all: bin arkade net brew
    earthly build .

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
    arkade get vcluster tflint terragrunt

# Installs arkade and earthly, bootstraps earthly and spits out docker ps
brew:
    brew install arkade earthly
    earthly bootstrap
    docker ps

VERSION 0.8

BUILD_DOCKER:
    FUNCTION
    ARG womp
    FROM DOCKERFILE ./$womp
    SAVE IMAGE lab:$womp-path-latest

# Note this was made with grep
all:
    DO +BUILD_DOCKER --womp=docs/portal
    DO +BUILD_DOCKER --womp=deps/docker-bitnami-pgvector
    DO +BUILD_DOCKER --womp=deps/base-images/ubuntu-fips-base
    DO +BUILD_DOCKER --womp=deps/base-images/loki
    DO +BUILD_DOCKER --womp=deps/base-images/mimir
    DO +BUILD_DOCKER --womp=deps/base-images/alloy
    DO +BUILD_DOCKER --womp=deps/base-images/rollout-operator
    DO +BUILD_DOCKER --womp=deps/base-images/amazonlinux-base
    DO +BUILD_DOCKER --womp=deps/base-images/amazonlinux-base/2023_hardened
    DO +BUILD_DOCKER --womp=deps/base-images/grafana
    DO +BUILD_DOCKER --womp=deps/base-images/atlantis
    DO +BUILD_DOCKER --womp=deps/base-images/python-nginx/3.9
    DO +BUILD_DOCKER --womp=deps/base-images/python3.13/python_nginx
    DO +BUILD_DOCKER --womp=deps/base-images/python3.13/build_base
    DO +BUILD_DOCKER --womp=deps/base-images/python3.13/python_base
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/sftp
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/jenkins/Jenkins-Worker
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/jenkins/Jenkins2
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/jenkins/Jenkins
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/jenkins/Jenkins-CI-Worker
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/awshelper
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/python-nginx/python3.9-buster
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/python-nginx/python3.10-buster
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/python-nginx/python3.6-alpine3.7
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/python-nginx/python3.6-buster
    DO +BUILD_DOCKER --womp=deps/cloud-automation/Docker/python-nginx/python2.7-alpine3.7
    DO +BUILD_DOCKER --womp=deps/cloud-automation/aws-inspec/docker
    DO +BUILD_DOCKER --womp=deps/fence # TODO two in there
    DO +BUILD_DOCKER --womp=deps/gen3-code-vigil/gen3-integration-tests/gen3_ci/ci_metrics
    DO +BUILD_DOCKER --womp=deps/gen3-code-vigil/gen3-integration-tests/gen3_ci/helm_cleanup
    DO +BUILD_DOCKER --womp=deps/gen3-code-vigil/gen3-integration-tests/gen3_ci/gcp_cleanup
    DO +BUILD_DOCKER --womp=deps/gen3-code-vigil/gen3-integration-tests/gen3_ci/ollama

broken:
    DO +BUILD_DOCKER --womp=deps/gen3-code-vigil/gen3-integration-tests 

needlogin:
    DO +BUILD_DOCKER --womp=deps/base-images/python_base/python3.9
    DO +BUILD_DOCKER --womp=deps/base-images/aws-es-proxy
    DO +BUILD_DOCKER --womp=deps/base-images/golang-build-base
    DO +BUILD_DOCKER --womp=deps/base-images/nodejs-base
    DO +BUILD_DOCKER --womp=deps/base-images/amazonlinux-debug
    DO +BUILD_DOCKER --womp=deps/base-images/python-build-base/3.9
    DO +BUILD_DOCKER --womp=deps/base-images/squid
    DO +BUILD_DOCKER --womp=deps/base-images/nodejs24-base

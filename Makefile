all: help

update: ## Update from the local helm chart repository
	@helm dependency update ./helm/gen3
	
local: DEPLOY=local
local: deploy ## Deploy the Local commons
local-context: change-context # Change to the Local context
local local-context: CONTEXT=rancher-desktop

development: DEPLOY=development
development: deploy zip ## Deploy the Development commons
development-context: change-context # Change to the Development contextt
development development-context: CONTEXT=arn:aws:eks:us-west-2:119548034047:cluster/aced-commons-development

staging: DEPLOY=staging
staging: deploy zip ## Deploy the Staging commons
staging-context: change-context # Change to the Staging context
staging staging-context: CONTEXT=arn:aws:eks:us-west-2:119548034047:cluster/aced-commons-staging

production: DEPLOY=production
production: deploy zip ## Deploy the Production commons
production-context: change-context  # Change to the Production context
production production-context: CONTEXT=arn:aws:eks:us-west-2:119548034047:cluster/aced-commons-production

context: ## Output the current Kubernetes context
	@echo "Current context: $(shell kubectl config current-context)"

change-context:
	@kubectl config use-context $(CONTEXT)

check-secrets:
	@printf "Checking Secrets..."
	@$(eval ACTUAL=$(shell [ -z $(shell readlink Secrets) ] && echo "<empty>" || echo $(shell readlink Secrets)))
	@[ "$(ACTUAL)" == "Secrets-$(DEPLOY)" ] || \
		(echo "Unexpected Secrets link"; \
		echo "Expected Secrets: Secrets-$(DEPLOY)"; \
		echo "Actual Secrets: $(ACTUAL)"; \
		exit 1)
	@echo "OK"

check-context:
	@printf "Checking Context..."
	@$(eval ACTUAL=$(shell kubectl config current-context))
	@[ "$(ACTUAL)" == "$(CONTEXT)" ] || \
		(echo "Unexpected Context"; \
		 echo "Expected Context: $(CONTEXT)"; \
		 echo "Actual Context: $(ACTUAL)"; \
		 exit 1)
	@echo "OK"

clean: check-clean ## Delete all existing deployments, configmaps, and secrets
	@$(eval ACTUAL=$(shell kubectl config current-context))
	@$(eval DEPLOY=$(shell case $(ACTUAL) in \
		(rancher-desktop) echo "local";; \
		(*development) 	  echo "development";; \
		(*staging)        echo "staging";; \
		(*production)     echo "production";; \
		esac)) \
	@read -p "Uninstall $(DEPLOY) deployment? [y/N]: " confirm && \
		case "$$confirm" in \
			[yY]) true;; \
			*) false;; \
		esac \
	@echo "Uninstalling $(DEPLOY)" \
	@-helm uninstall $(DEPLOY) \
	@kubectl delete secrets --all \
	@kubectl delete configmaps --all \
	@kubectl delete jobs --all \

deploy: check-context check-secrets
	@echo "Deploying $(DEPLOY)"
	@if [ "$(DEPLOY)" = "local" ]; then \
		helm upgrade --install $(DEPLOY) ./helm/gen3 \
			-f Secrets/values.yaml \
			-f Secrets/user.yaml \
			-f Secrets/fence-config.yaml \
			-f Secrets/TLS/gen3-certs.yaml; \
	else \
		helm upgrade --install $(DEPLOY) ./helm/gen3 \
			-f Secrets/values.yaml \
			-f Secrets/user.yaml \
			-f Secrets/fence-config.yaml; \
	fi

# Create a timestamped Secrets archive and copy to $HOME/OneDrive/ACED-deployments
zip: 
	@$(eval TIMESTAMP="$(DEPLOY)-$(shell date +"%Y-%m-%dT%H-%M-%S%z")")
	@zip Secrets-$(TIMESTAMP).zip Secrets
	@cp Secrets-$(TIMESTAMP).zip $(HOME)/OneDrive/ACED-deployments

# https://gist.github.com/prwhite/8168133
help:	## Show this help message
	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m\033[1m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: debug deploy clean check-clean zip help change-context
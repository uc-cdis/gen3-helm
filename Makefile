all: help

update: ## Update from the local helm chart repository
	@helm dependency update ./helm/gen3

local: DEPLOY=local
local: local-context deploy ## Deploy the Local commons
local-context: change-context # Change to the Local context
local local-context: CONTEXT=rancher-desktop

development: DEPLOY=development
development: development-context deploy ## Deploy the Development commons
development-context: change-context # Change to the Development contextt
development development-context: CONTEXT=arn:aws:eks:us-west-2:119548034047:cluster/aced-commons-development

staging: DEPLOY=staging
staging: check-context deploy ## Deploy the Staging commons
staging-context: change-context # Change to the Staging context
staging staging-context: CONTEXT=arn:aws:eks:us-west-2:119548034047:cluster/aced-commons-staging

production: DEPLOY=production
production: check-context deploy ## Deploy the Production commons
production-context: change-context  # Change to the Production context
production production-context: CONTEXT=arn:aws:eks:us-west-2:119548034047:cluster/aced-commons-production

cbds: DEPLOY=cbds
cbds: check-context deploy ## Deploy the cbds production commons
cbds-context: change-context  # Change to the cbds production context
cbds cbds-context: CONTEXT=cbds

cbds-dev: DEPLOY=cbds-dev
cbds-dev: check-context deploy ## Deploy the cbds development commons
cbds-dev-context: change-context  # Change to the cbds development context
cbds-dev cbds-dev-context: CONTEXT=cbds-dev

context: ## Output the current Kubernetes context
	@echo "Current context: $(shell kubectl config current-context)"

change-context:
	@kubectl config use-context $(CONTEXT)

check-secrets:
	@$(eval ACTUAL=$(shell [ -z $(shell readlink Secrets) ] && echo "<empty>" || echo $(shell readlink Secrets)))
	@[ "$(ACTUAL)" == "Secrets-$(DEPLOY)" ] || \
	(printf "\033[1mUnexpected Secrets link\033[0m\n"; \
	 printf "\033[92mExpected Secrets:\033[0m Secrets-$(DEPLOY)\n"; \
	 printf "\033[93mActual Secrets:\033[0m   $(ACTUAL)\n"; \
	 read -p "Change Secrets link to $(DEPLOY)? [y/N]: " sure && \
	 	case "$$sure" in \
	 		[yY]) true;; \
	 		*) exit 1;; \
	 	esac; \
	 rm -f Secrets; \
	 echo "Changing Secrets link to Secrets-$(DEPLOY)"; \
	 ln -s Secrets-$(DEPLOY) Secrets)

check-context:
	@$(eval ACTUAL=$(shell kubectl config current-context))
	@[ $(ACTUAL) == $(CONTEXT) ] || \
		(printf "\033[1mUnexpected context\033[0m\n"; \
		 printf "\033[92mExpected context:\033[0m $(CONTEXT)\n"; \
		 printf "\033[93mActual context:\033[0m   $(ACTUAL)\n"; \
		 exit 1)

check-venv:
	@if [ ! -d "venv" ]; then \
		$(MAKE) create-venv; \
	elif [ -z "$$(source venv/bin/activate && python -c 'import pkgutil; exit(not all(pkgutil.find_loader(pkg) for pkg in ["click", "requests", "urllib3"]))')" ]; then \
		echo "Existing venv found with required packages installed."; \
		echo "$(pwd)/venv"; \
	else \
		$(MAKE) create-venv; \
	fi

create-venv:
	@python3 -m venv venv; \
	source venv/bin/activate; \
	pip install click requests urllib3; \
	echo "New venv created with required packages installed."; \
	echo "$(pwd)/venv";

clean: check-clean ## Delete all existing deployments, configmaps, and secrets
	@$(eval ACTUAL=$(shell kubectl config current-context))
	@$(eval DEPLOY=$(shell case $(ACTUAL) in \
		(rancher-desktop) echo "local";; \
		(*development) 		echo "development";; \
		(*staging) 				echo "staging";; \
		(*production) 		echo "production";; \
	esac))

	@read -p "Uninstall $(DEPLOY) deployment? [y/N]: " sure && \
		case "$$sure" in \
			[yY]) true;; \
			*) false;; \
		esac
	@echo "Uninstalling $(DEPLOY)"

	@-helm uninstall $(DEPLOY)
	@kubectl delete secrets --all
	@kubectl delete configmaps --all
	@kubectl delete jobs --all

deploy: check-context check-secrets
	@echo "Deploying $(DEPLOY)"
	@if [ "$(DEPLOY)" = "local" ]; then \
		helm upgrade --install "$(DEPLOY)" ./helm/gen3 \
		-f Secrets/values.yaml \
		-f Secrets/user.yaml \
		-f Secrets/fence-config.yaml \
		-f Secrets/TLS/gen3-certs.yaml; \
	elif [ "$(DEPLOY)" = "cbds-dev" ]; then \
		helm upgrade --install "local" ./helm/gen3 \
		-f Secrets/values.yaml \
		-f Secrets/user.yaml \
		-f Secrets/fence-config.yaml \
		-f Secrets/gen3-certs.yaml; \
	else \
		helm upgrade --install "$(DEPLOY_NEW)" ./helm/gen3 \
		-f Secrets/values.yaml \
		-f Secrets/user.yaml \
		-f Secrets/fence-config.yaml; \
	fi

# https://gist.github.com/prwhite/8168133
help:	## Show this help message
	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m\033[1m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: debug deploy clean check-clean zip help change-context

#################
# SECRET SERVER #
#################
# venv will be created if it doesn't exist
VENV := venv
SCRIPT := SSClient.py

# eg: fetch-secrets ENV=local or development, etc
fetch-secrets: check-venv
	@echo "Fetching $(ENV)"
	$(VENV)/bin/python $(SCRIPT) get $(ENV);

# eg: push-secrets ENV=local or local_test or development, etc
push-secrets: check-venv
	@read -p "Update Secret Server secrets for $(ENV)? [y/N]: " sure && \
		case "$$sure" in \
			[yY]) true;; \
			*) echo "secrets were not updated in SS" && false;; \
		esac
	$(VENV)/bin/python $(SCRIPT) post "$(ENV)"

list-secrets: check-venv
	$(VENV)/bin/python $(SCRIPT) list;

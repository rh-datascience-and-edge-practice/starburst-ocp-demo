DEFAULT_ENV_FILE := .env
ifneq ("$(wildcard $(DEFAULT_ENV_FILE))","")
	include ${DEFAULT_ENV_FILE}
	export $(shell sed 's/=.*//' ${DEFAULT_ENV_FILE})
endif

ENV_FILE := .env.local
ifneq ("$(wildcard $(ENV_FILE))","")
	include ${ENV_FILE}
	export $(shell sed 's/=.*//' ${ENV_FILE})
endif



##################################

.PHONY: deploy
deploy: login deploy-customer deploy-finance deploy-kafka deploy-starburst-enterprise deploy-starburst-hive

##################################

.PHONY: undeploy
undeploy: login undeploy-customer undeploy-finance undeploy-kafka undeploy-starburst-enterprise undeploy-starburst-hive

##################################

.PHONY: login
login:
ifdef OC_TOKEN
	$(info **** Using OC_TOKEN for login ****)
	oc login ${OC_URL} --token=${OC_TOKEN}
else
	$(info **** Using OC_USER and OC_PASSWORD for login ****)
	oc login ${OC_URL} -u ${OC_USER} -p ${OC_PASSWORD} --insecure-skip-tls-verify=true
endif

##################################

.PHONY: deploy-customer
deploy-customer: login
	echo ${CUSTOMER_DATABASE_NAME}
	sh ./customer/deploy.sh


##################################

.PHONY: undeploy-customer
undeploy-customer: login
	sh ./customer/undeploy.sh

##################################

.PHONY: deploy-finance
deploy-finance: login
	echo ${TRANSACTION_DATABASE_NAME}
	sh ./finance/deploy.sh


##################################

.PHONY: undeploy-finance
undeploy-finance: login
	sh ./finance/undeploy.sh

##################################

.PHONY: deploy-starburst-enterprise
deploy-starburst-enterprise: login 
	sh ./starburst-enterprise/deploy.sh

##################################

.PHONY: undeploy-starburst-enterprise
undeploy-starburst-enterprise: login
	sh ./starburst-enterprise/undeploy.sh

##################################

.PHONY: deploy-starburst-hive
deploy-starburst-hive: login 
	sh ./starburst-hive/deploy.sh

##################################

.PHONY: undeploy-starburst-hive
undeploy-starburst-hive: login
	sh ./starburst-hive/undeploy.sh

##################################

.PHONY: deploy-kafka
deploy-kafka: login
	sh ./kafka/deploy.sh

##################################

.PHONY: undeploy-kafka
undeploy-kafka: login
	sh ./kafka/undeploy.sh

##################################


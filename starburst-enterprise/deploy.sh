#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

oc project ${OC_PROJECT} 2> /dev/null || oc new-project ${OC_PROJECT}
oc project

printf "\n\n######## deploy starburst instance ########\n"

oc apply -f "${DIR}/resources/starburst.yaml" --wait=true

oc wait starburstenterprise/starburstenterprise-sample --for=condition=Ready --timeout=60s

oc expose service coordinator 


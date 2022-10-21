#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

oc project ${OC_PROJECT} 2> /dev/null || oc new-project ${OC_PROJECT}
oc project

printf "\n\n######## deploy postgres instance ########\n"

oc apply -f "${DIR}/resources/postgres-db.yaml" --wait

echo "waiting on postgres database deployment...."
sleep 60

echo "database setup...."
sh ${DIR}/scripts/setup-database.sh


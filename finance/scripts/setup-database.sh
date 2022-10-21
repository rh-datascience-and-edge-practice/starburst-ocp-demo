#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "create table...."
POD=$(oc get pods | grep -i finance-domain | awk '{print $1}' )
oc exec ${POD} -- bash -c "psql -U postgres -c \"CREATE DATABASE example\""

echo "copying scripts to pod...."
oc cp ${DIR}/create-transactions-table.sql ${POD}:/tmp/create-transactions-table.sql 
oc cp ${DIR}/insert-transactions-data.sql ${POD}:/tmp/insert-transactions-data.sql 

echo "copying data to pod...." 
oc cp ${DIR}/../data/fake-data.csv ${POD}:/tmp/fake-data.csv 

echo "running scripts...."
oc exec $POD -- bash -c "psql -U postgres -d example < /tmp/create-transactions-table.sql" 
oc exec $POD -- bash -c "psql -U postgres -d example < /tmp/insert-transactions-data.sql"

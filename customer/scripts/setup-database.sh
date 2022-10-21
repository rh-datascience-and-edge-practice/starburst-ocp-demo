#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "create table...."
POD=$(oc get pods | grep -i customer | awk '{print $1}' )
oc exec ${POD} -- bash -c "psql -U postgres -c \"CREATE DATABASE example\""

echo "copying scripts to pod...."
oc cp ${DIR}/create-customer-table.sql ${POD}:/tmp/create-customer-table.sql 
oc cp ${DIR}/insert-customer-data.sql ${POD}:/tmp/insert-customer-data.sql 

echo "copying data to pod...." 
oc cp ${DIR}/../data/fake-data.csv ${POD}:/tmp/fake-data.csv 

echo "running scripts...."
oc exec $POD -- bash -c "psql -U postgres -d example < /tmp/create-customer-table.sql" 
oc exec $POD -- bash -c "psql -U postgres -d example < /tmp/insert-customer-data.sql"

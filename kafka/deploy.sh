#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

oc project ${OC_PROJECT} 2> /dev/null || oc new-project ${OC_PROJECT}
oc project

printf "\n\n######## deploy kafka instance ########\n"

oc apply -f "${DIR}/resources/chatbot-kafka.yaml"
oc wait kafka/chatbot --for=condition=Ready --timeout=300s

printf "\n\n######## deploy kafka topics ########\n"

oc apply -f "${DIR}/resources/messages-topic.yaml"



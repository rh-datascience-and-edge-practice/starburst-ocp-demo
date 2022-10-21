#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
oc project ${OC_PROJECT} && \
oc delete -f "${DIR}/resources/chatbot-kafka.yaml"
oc delete -f "${DIR}/resources/messages-topic.yaml"


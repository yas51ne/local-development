#!/bin/sh
set -o errexit

# To install Knative, first install the CRDs by running the kubectl apply command once with the -l knative.dev/crd-install=true flag. 
# This prevents race conditions during the install, which cause intermittent errors:

kubectl apply --selector knative.dev/crd-install=true \
--filename serving.yaml \
--filename release.yaml \
--filename monitoring.yaml

# wait for CRD to be created
sleep 15

# To complete the install of Knative and its dependencies, run the kubectl apply command again, 
# this time without the --selector flag, to complete the install of Knative and its dependencies:

kubectl apply --filename serving.yaml \
--filename release.yaml \
--filename monitoring.yaml
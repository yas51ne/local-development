#!/bin/sh
set -o errexit

# Install the Istio CRDs
for i in istio-init/crd*yaml; do kubectl apply -f $i; done

# Wait a few seconds for the CRDs to be committed in the Kubernetes API-server, then continue with these instructions.
sleep 60

# Create istio-system namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: istio-system
  labels:
    istio-injection: disabled
EOF

# Installing Istio with sidecar injection
kubectl apply -f istio-lean.yaml

# Updating your install to use cluster local gateway
kubectl apply -f istio-knative-extras.yaml
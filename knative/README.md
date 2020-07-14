# What is Knative? 
Kubernetes-based platform for serverless workloads. Knative provides a set of middleware components that are essential to build modern, source-centric, and container-based applications that can run anywhere: on premises, in the cloud, or even in a third-party data center.

# Installation

Knative version: **v0.11.0**

The following commands install all available Knative components. To customize your Knative installation, see Performing a Custom Knative Installation.

1. To install Knative, first install the CRDs by running the kubectl apply command once with the -l knative.dev/crd-install=true flag. This prevents race conditions during the install, which cause intermittent errors:
```bash
kubectl apply --selector knative.dev/crd-install=true \
--filename serving.yaml \
--filename release.yaml \
--filename monitoring.yaml
```
2. To complete the install of Knative and its dependencies, run the kubectl apply command again, this time without the --selector flag, to complete the install of Knative and its dependencies:
```bash
kubectl apply --filename serving.yaml \
--filename release.yaml \
--filename monitoring.yaml
```
3. Monitor the Knative components until all of the components show a STATUS of Running:
```bash
kubectl get pods --namespace knative-serving
kubectl get pods --namespace knative-eventing
kubectl get pods --namespace knative-monitoring
```
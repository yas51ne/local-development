# Istio

An open platform to connect, manage, and secure microservices.

- For in-depth information about how to use Istio, visit [istio.io](https://istio.io)                                   
- To ask questions and get assistance from our community, visit [discuss.istio.io](https://discuss.istio.io)
- To learn how to participate in our overall community, visit [our community page](https://istio.io/about/community)

You'll find many other useful documents on this [Wiki](https://github.com/istio/istio/wiki).

## Introduction

Istio is an open platform for providing a uniform way to integrate
microservices, manage traffic flow across microservices, enforce policies
and aggregate telemetry data. Istio's control plane provides an abstraction
layer over the underlying cluster management platform, such as Kubernetes.

Istio is composed of these components:

- **Envoy** - Sidecar proxies per microservice to handle ingress/egress traffic
   between services in the cluster and from a service to external
   services. The proxies form a _secure microservice mesh_ providing a rich
   set of functions like discovery, rich layer-7 routing, circuit breakers,
   policy enforcement and telemetry recording/reporting
   functions.

  > Note: The service mesh is not an overlay network. It
  > simplifies and enhances how microservices in an application talk to each
  > other over the network provided by the underlying platform.

- **Mixer** - Central component that is leveraged by the proxies and microservices
   to enforce policies such as authorization, rate limits, quotas, authentication, request
   tracing and telemetry collection.

- **Pilot** - A component responsible for configuring the proxies at runtime.

- **Citadel** - A centralized component responsible for certificate issuance and rotation.

- **Citadel Agent** - A per-node component responsible for certificate issuance and rotation.

- **Galley**- Central component for validating, ingesting, aggregating, transforming and distributing config within Istio.

Istio currently supports Kubernetes and Consul-based environments. We plan support for additional platforms such as
Cloud Foundry, and Mesos in the near future.

## Repositories

The Istio project is divided across a few GitHub repositories.

- [istio/istio](README.md). This is the main repository that you are
currently looking at. It hosts Istio's core components and also
the sample programs and the various documents that govern the Istio open source
project. It includes:
  - [security](security/). This directory contains security related code,
including Citadel (acting as Certificate Authority), citadel agent, etc.
  - [pilot](pilot/). This directory
contains platform-specific code to populate the
[abstract service model](https://istio.io/docs/concepts/traffic-management/overview.html), dynamically reconfigure the proxies
when the application topology changes, as well as translate
[routing rules](https://istio.io/docs/reference/config/istio.networking.v1alpha3/) into proxy specific configuration.
  - [istioctl](istioctl/). This directory contains code for the
[_istioctl_](https://istio.io/docs/reference/commands/istioctl.html) command line utility.
  - [mixer](mixer/). This directory
contains code to enforce various policies for traffic passing through the
proxies, and collect telemetry data from proxies and services. There
are plugins for interfacing with various cloud platforms, policy
management services, and monitoring services.

- [istio/api](https://github.com/istio/api). This repository defines
component-level APIs and common configuration formats for the Istio platform.

- [istio/proxy](https://github.com/istio/proxy). The Istio proxy contains
extensions to the [Envoy proxy](https://github.com/envoyproxy/envoy) (in the form of
Envoy filters), that allow the proxy to delegate policy enforcement
decisions to Mixer.

## Installation
Istio Version: **1.3.5**

### Automatic installation
Enter the following command to install Istio:
```bash
sh deploy-istio-for-knative.sh
```
### Manual installation
#### Installing Istio CRDs and namespace
Enter the following command to install the Istio CRDs first:
```bash
for i in istio-init/crd*yaml; do kubectl apply -f $i; done
```
Wait a few seconds for the CRDs to be committed in the Kubernetes API-server, then continue with these instructions.

Create istio-system namespace:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: istio-system
  labels:
    istio-injection: disabled
EOF
```

#### Installing Istio without sidecar injection
Enter the following command to install Istio without sidecar injection:
```bash
kubectl apply -f istio-lean.yaml
```
#### Installing Istio with sidecar injection
Enter the following command to install Istio with sidecar injection:
```bash
kubectl apply -f istio.yaml
```
#### Installing Istio with SDS to secure the ingress gateway

Enter the following command to install Istio with SDS to secure the ingress gateway:
```bash
kubectl apply -f istio-sds.yaml
```
#### Updating your install to use cluster local gateway
Enter the following command to add the cluster local gateway to an existing Istio installation:
```bash
kubectl apply -f istio-local-gateway.yaml
```
Alternatively, if you want to install the cluster local gateway for **development purposes**, enter the following command for an easy installation:

```bash
# Istio minor version should be 1.3
kubectl apply -f istio-knative-extras.yaml
```
#### Configuring DNS
TODO
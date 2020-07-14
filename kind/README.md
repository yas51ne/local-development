# Development Environment
## Introduction
The development environment consists of a kubernetes cluster deployed on the developers local hosts.
To deploy this environment to a local developer machine, we use [kind](https://github.com/kubernetes-sigs/kind). It is a tool for running local Kubernetes clusters using Docker container “nodes”.
## Why kind?
   * kind supports multi-node (including HA) clusters
   * kind supports building Kubernetes release builds from source (make, bash, docker,...)
   * kind supports Linux, macOS and Windows
   * kind is a CNCF certified conformant Kubernetes installer

## Requirements
You need to have ```Docker``` and ```kubectl``` installed on your host machine.
* To install Docker  : https://docs.docker.com/install/
* To install kubectl : https://kubernetes.io/docs/tasks/tools/install-kubectl/

## kind installation
kind is used in this project for local development and deployment in Kubernetes.
### On Linux:
```bash
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind
```
### On Mac:
```bash
brew install kind
```
### On Windows:
```bash
curl.exe -Lo kind-windows-amd64.exe https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe
```
## Local Development environement installation
Creating a Kubernetes cluster is as simple as ```kind create cluster```.
If you want the ```create cluster``` command to block until the control plane reaches a ready status, you can use the ```--wait``` flag and specify a timeout. To use ```--wait``` you must specify the units of the time to wait. For example, to wait for 30 seconds, do ```--wait 30s```, for 5 minutes do ```--wait 5m```, etc.
For the project needs, a script was developed to install all required components.
### Creating the development kubernetes cluster
To deploy the development cluster run this ```deploy-developement-environement.sh``` script as root:
```bash
sudo sh deploy-developement-environement.sh
```
## Stoping and Starting the servers
### Stoping the servers
To stop the running containers run the following command:
```bash
for server in `docker ps --all --format '{{.Names}}' --filter "name=local-developement"` ; do docker stop $server ; done
```
### Start the servers
To start the running containers run the following command:
```bash
for server in `docker ps --all --format '{{.Names}}' --filter "name=local-developement"` ; do docker start $server ; done
```
## Local Development environement removal
### Deleting the kubernetes cluster
If you want to delete the development cluster with kind then run:
```bash
kind delete cluster --name local-developement
```
### Deleting the registry server
```bash
sudo docker rm -f local-developement-registry
```
### Deleting the DNSmasq server
```bash
sudo docker rm -f local-developement-dnsmasq
```
## Using The Registry

The registry can be used like this.

  1.  Before starting pull the ```hashicorp/http-echo``` image from DockerHub:
     ```docker  pull hashicorp/http-echo```
  2.  First tag the image to use the local registry: 
     ```docker tag hashicorp/http-echo registry.local-developement.eu:5000/http-echo```
  3.  Then push it to the registry:
     ```docker push registry.local-developement.eu:5000/http-echo```
  4.  And now you can use the image: 
     ```kubectl apply -f test-app.yaml```
  5.  Finally, try:
      ```curl app.local-developement.eu/dev``` it should output "dev"
      ```curl app.local-developement.eu/ops``` it should output "ops"


## Additional Resources
Here are some additional resources for learning about KIND and how to use it.
* https://kind.sigs.k8s.io/docs/user/resources/

# Contact

**Yassine MAACHI**: y.m@yassinemaachi.com
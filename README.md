# Development Environment

The development environment consists the required technologies and how to install it in your local host (MacOS) in order to start developing extraordinary:
- serverless applications with **knative**
- micro-services with **istio**
- kubernetes resources with **kin**

## Requirements
1. You need to have ```Docker``` and ```kubectl``` installed on your host machine.
* To install Docker  : https://docs.docker.com/install/
* To install kubectl : https://kubernetes.io/docs/tasks/tools/install-kubectl/
2. To have Istio on your local host, you will need at least 6cpu and 8GB of RAM.
* To change the resource limits for the Docker on Mac, you'll need to open the **Preferences** menu.
![Preferences](/img/increase-docker-ressources-1.png)
* Now, go to the **Advanced** settings section, and change the settings there. Then **Apply & Restart**:
![Advanced](/img/increase-docker-ressources-2.png)

## Installation
### Automatic installation
Run the ```deploy-*.sh``` scripts in each directory as the following:
```bash
cd kind/
sudo sh deploy-developement-environement.sh
cd ../istio/
sudo sh deploy-istio-for-knative.sh
cd ../knative/
sudo sh deploy-knative.sh
```
### Manual installation
You need to install the components in the following order:
1. kind
2. istio
3. knative

You will find the installation instructions for these components in their appropriate directories.
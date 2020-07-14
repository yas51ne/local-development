#!/bin/sh
set -o errexit

# desired cluster name; default is "local-developement"
KIND_CLUSTER_NAME="${KIND_CLUSTER_NAME:-local-developement}"
dns_name='local-developement-dnsmasq'
dns_domaine='local-developement.com'
dns_port='53'
dns_web_port='5380'
dns_config=`pwd`
dns_web_login='devadmin'
dns_web_pass='dev@local2020'
reg_name='local-developement-registry'
reg_port='5000'
k8s_version='v1.18.0'
# create registry container unless it already exists
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi
echo "*****************************************************************"
echo "Registry server deployed !"
# create dnsmasq container unless it already exists
running="$(docker inspect -f '{{.State.Running}}' "${dns_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
        --name "${dns_name}" \
        -d \
        -p "${dns_port}:53/udp" \
        -p "${dns_web_port}:8080" \
        -v "${dns_config}/dnsmasq.conf:/etc/dnsmasq.conf" \
        --log-opt "max-size=100m" \
        -e "HTTP_USER=${dns_web_login}" \
        -e "HTTP_PASS=${dns_web_pass}" \
        --restart always \
        jpillora/dnsmasq
fi

# OS X also allows you to configure additional resolvers by creating configuration files in the /etc/resolver/ directory. 
# This directory probably won’t exist on the system, so we should create it
mkdir -p /etc/resolver

# Create a new file with the same name as your new top-level domain in the /etc/resolver/ directory and add a nameserver 
# to it by running the following command
tee /etc/resolver/local-developement.com >/dev/null <<EOF
nameserver 127.0.0.1
EOF
echo "*****************************************************************"
echo "DNS server deployed !"
# To specify a configuration file when creating a cluster, use the --config flag
echo "*****************************************************************"
cat <<EOF | kind create cluster --name "${KIND_CLUSTER_NAME}"  --image "kindest/node:${k8s_version}" --config=-
# a cluster with 1 control-plane node and 3 workers
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  # WARNING: It is _strongly_ recommended that you keep this the default
  # (127.0.0.1) for security reasons. However it is possible to change this.
  apiServerAddress: "127.0.0.1"
  # By default the API server listens on a random open port.
  # You may choose a specific port but probably don't need to in most cases.
  # Using a random port makes it easier to spin up multiple clusters.
  apiServerPort: 6443
  # You can configure the subnet used for pod IPs by setting
  podSubnet: "10.244.0.0/16"
  # You can configure the Kubernetes service subnet used for service IPs by setting
  serviceSubnet: "10.96.0.0/12"
containerdConfigPatches: 
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.${dns_domaine}:${reg_port}"]
    endpoint = ["http://registry.${dns_domaine}:${reg_port}"]
nodes:
# The API-server and other control plane components will be
# on the control-plane node.
- role: control-plane
  # add a mount from /path/to/my/files on the host to /files on the node
  extraMounts:
  - hostPath: ~/Documents/kindpercistence/
    containerPath: /kindpercistence
  # Custom node label by using node-labels in the kubeadm InitConfiguration, 
  # to be used by the ingress controller nodeSelector.
  kubeadmConfigPatches:
  - |
    apiVersion: kubeadm.k8s.io/v1beta2
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
        authorization-mode: "AlwaysAllow"
  extraPortMappings:
  # port forward 80 on the host to 80 on this node
  - containerPort: 80
    hostPort: 80
    # optional: set the protocol to one of TCP, UDP, SCTP.
    # TCP is the default
    protocol: TCP
  # port forward 443 on the host to 443 on this node
  - containerPort: 443
    hostPort: 443
    # optional: set the protocol to one of TCP, UDP, SCTP.
    # TCP is the default
    protocol: TCP
- role: worker
  # add a mount from /path/to/my/files on the host to /files on the node
  extraMounts:
  - hostPath: ~/Documents/kindpercistence/
    containerPath: /kindpercistence
- role: worker
  # add a mount from /path/to/my/files on the host to /files on the node
  extraMounts:
  - hostPath: ~/Documents/kindpercistence/
    containerPath: /kindpercistence
- role: worker
  # add a mount from /path/to/my/files on the host to /files on the node
  extraMounts:
  - hostPath: ~/Documents/kindpercistence/
    containerPath: /kindpercistence
EOF

# add the local-developement-registry to /etc/hosts on each node
ip_fmt='{{.NetworkSettings.IPAddress}}'
cmd="echo $(docker inspect -f "${ip_fmt}" "${reg_name}") registry."${dns_domaine}" >> /etc/hosts"
for node in $(kind get nodes --name "${KIND_CLUSTER_NAME}"); do
  docker exec "${node}" sh -c "${cmd}"
done

# Apply the mandatory ingress-nginx components
kubectl apply -f ingress-nginx-mandatory.yaml

# Expose the nginx service using NodePort
kubectl apply -f ingress-nginx-service-nodeport.yaml

# Waiting for deployment "nginx-ingress-controller" rollout to finish
kubectl -n ingress-nginx rollout status deploy/nginx-ingress-controller

# Apply kind specific patches to forward the hostPorts to the ingress controller, 
# set taint tolerations and schedule it to the custom labelled node
kubectl patch deployments -n ingress-nginx nginx-ingress-controller -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-ingress-controller","ports":[{"containerPort":80,"hostPort":80},{"containerPort":443,"hostPort":443}]}],"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}' 

# Waiting for deployment "nginx-ingress-controller" rollout to finish
kubectl -n ingress-nginx rollout status deploy/nginx-ingress-controller

echo "*****************************************************************"
echo "Registry server deployed, you can push your images to: \n      >>> registry.${dns_domaine}:${reg_port} \n       *  User: N/A \n       *  Password: N/A"
echo "*****************************************************************"
echo "DNS server deployed, you can access the admin web interface at: \n      >>> http://dnsmasq.${dns_domaine}:${dns_web_port} \n       *  User: ${dns_web_login} \n       *  Password: ${dns_web_pass}"
echo "*****************************************************************"
echo "Ingress Controller deployed, you can use this domain: \n      >>> http://*.${dns_domaine}\n      >>> https://*.${dns_domaine}"
echo "*****************************************************************"
echo "You can now use your cluster with:"
echo "   kubectl cluster-info --context kind-${KIND_CLUSTER_NAME}"
echo "*****************************************************************"
echo "To deploy an application in order to test the installation, do the following: "
echo "  1.  Before starting pull the hashicorp/http-echo image from DockerHub:"
echo "    $ docker pull hashicorp/http-echo"
echo "  2.  First tag the image to use the local registry:"
echo "    $ docker tag hashicorp/http-echo registry.local-developement.com:5000/http-echo"
echo "  3.  Then push it to the registry:"
echo "    $ docker push registry.local-developement.com:5000/http-echo"
echo "  4.  And now you can use the image:"
echo "    $ kubectl apply -f test-app.yaml"
echo "  5.  Finally, try:"
echo "    $ curl app.local-developement.com/dev (it should output: dev)"
echo "    $ curl app.local-developement.com/ops (it should output: ops)"

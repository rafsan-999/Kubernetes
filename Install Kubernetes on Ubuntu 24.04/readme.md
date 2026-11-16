# Kubernetes lab setup
To demonstrate the installation of Kubernetes, we have a three-cluster setup comprising a master node and two worker nodes. Kubernetes can support up to 5000 nodes. Below is our cluster setup.

<img width="854" height="162" alt="image" src="https://github.com/user-attachments/assets/52177c01-02f8-4cb0-8e65-704058f68f6f" />

Let us now dive in and install Kubernetes on Ubuntu 24.04.
# How to install Kubernetes on Ubuntu 24.04
Management of containerized applications/microservices at scale - especially across multiple cloud providers can be daunting and fraught with errors when done manually. The best approach is to leverage an orchestration tool. This is where Kubernetes comes in.

Originally developed by Google, Kubernetes has become a popular container management platform. It automates the deployment, scaling, and management of container applications at scale, eliminating bottlenecks associated with the manual management of container applications.


# Step 1: Configure hostnames (all nodes)
Start by updating the /etc/hosts files and specifying the IP addresses and hostnames for each node in the cluster. This will allow seamless communication between the master and worker nodes.
So, access the /etc/hosts file.

    sudo  nano  /etc/hosts
Add the following entries for master and worker node. This will allow for hostname resolution. Replace the IP addresses and hostnames with your own

    10.209.99.21    k8s-master
    10.209.99.22    k8s-worker-01
    10.209.99.23    k8s-worker-02
    10.209.99.24    k8s-worker-03
## To effect the hostname changes, run
    sudo exec bash
## To verify the hostname in each node, run the command:
    hostname
In addition, ensure you can ping all the nodes in the setup from each node using the configured hostnames. The following example below shows the master node pinging the two worker nodes.

    ping -c 3 k8s-worker-01
    ping -c 3 k8s-worker-02
    ping -c 3 k8s-worker-03

# Step 2: Disable swap space (all nodes)
Disabling swap space is a standard requirement for installing Kubernetes. The reason is that swap degrades performance since it’s slower for the kernel to access it than RAM. Disabling it ensures consistent application performance without the unpredictability of swap usage.
To disable swap on the nodes, run the command:

    sudo swapoff -a
The command above disables swap temporarily. To persist the change upon a reboot, access the /etc/fstab file and comment out the swap entry by adding the # symbol before the swap entry.
To check whether the swap space has been disabled, run the command:

    swapon --show

The output will be blank, indicating that the swap space has been disabled.

<img width="549" height="130" alt="image" src="https://github.com/user-attachments/assets/40210d29-9532-4098-b6af-1fa3d689a7c0" />

# Step 3: Load Containerd modules (all nodes)
Containerd is the standard container runtime for Kubernetes. For the seamless running of this runtime, it is recommended that the overlay and br_netfilter kernel modules be loaded. To enable and load these modules, run the following commands:

    sudo modprobe overlay
    sudo modprobe br_netfilter
Create a configuration file as shown and specify the modules to load them permanently.

    sudo tee /etc/modules-load.d/k8s.conf <<EOF
    overlay
    br_netfilter
    EOF

# Step 4: Configure Kubernetes IPv4 networking (all nodes)
It's important to configure Kubernetes networking so that pods can communicate with each other and outside environments without a hitch.

Create a Kubernetes configuration file in the /etc/sysctl.d/ directory.
Add the following lines:

    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward   = 1
Save and exit. Then apply the settings by running the following command:

    sudo sysctl --system

# Step 5: Install Docker (on all nodes)
In Kubernetes, Docker creates and manages containers on each node in the cluster while Kubernetes orchestrates the deployment, scaling, monitoring, and management of containerized applications. The two work in tandem to manage microservice applications at a large scale.

Ubuntu provides Docker from its default repositories. To install it, run the following commands on all nodes.

    sudo apt update
    sudo apt install docker.io -y
To verify if Docker is running, run:

    sudo systemctl status docker
In addition, be sure to enable the Docker daemon to autostart on system startup or upon a reboot.

    sudo systemctl enable docker
The installation of Docker also comes with containerd, a lightweight container runtime that streamlines the running and management of containers. As such, configure containerd to ensure it runs reliably in the Kubernetes cluster.

First, create a separate directory as shown.

    sudo mkdir /etc/containerd
Next, create a default configuration file for containerd.

    sudo sh -c "containerd config default > /etc/containerd/config.toml"
Update the SystemdCgroup directive by setting it to true as shown.

    sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
Next, restart the containerd service to apply the changes made.

    sudo systemctl restart containerd.service
Be sure to verify that the containerd service is running as expected.

    sudo systemctl status containerd.service

# Step 6: Install Kubernetes components (on all nodes)
The next step is to install Kubernetes. Currently, Kubernetes v1.34 is the current version. Be sure to install the prerequisite packages on all nodes.

    sudo apt-get install curl ca-certificates apt-transport-https  -y
Add the Kubernetes GPG signing key.

    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
Thereafter, add the official Kubernetes repository to your system.

    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
Once added, update the sources list for the system to recognize the newly added repository.

    sudo apt update
To install Kubernetes, we will install three packages:

kubeadm: This is a command-line utility for setting up Kubernetes clusters. It automates setting up a cluster, streamlining container deployments, and abstracting any complexities within the cluster. With kubeadm you can initialize the control-plane, configure networking, and join a remote node to a cluster.

kubelet: This is a component that actively runs on each node in a cluster to oversee container management. It takes instructions from the master node and ensures containers run as expected.

kubectl: This is a CLI tool for managing various cluster components including pods, nodes, and the cluster. You can use it to deploy applications and inspect, monitor, and view logs.

To install these salient Kubernetes components, run the following command:

    sudo apt install kubelet kubeadm kubectl -y
# Step 7: Initialize Kubernetes cluster (on master node)
The next step is to initialize the Kubernetes cluster on the master node. This configures the master node as the control plane. To initialize the cluster, run the command shown. The --pod-network-cidr indicates a unique pod network for the cluster, in this case, the 10.10.0.0 network with a CIDR of /16.

    sudo kubeadm init --pod-network-cidr=10.10.0.0/16
Therefore, run the commands as a regular user. Create a .kube directory in your home directory.

    mkdir -p $HOME/.kube
Next, copy the cluster's configuration file to the .kube directory.

    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
Lastly, configure the ownership of the copied configuration file to allow the user to leverage the config file to manage the cluster.

    sudo chown $(id -u):$(id -g) $HOME/.kube/config
# Step 8: Install Calico network add-on plugin
Developed by Tigera, Calico provides a network security solution in a Kubernetes cluster. It secures communication between individual pods as well as pods and external services. By auto-assigning IP addresses to pods, it ensures smooth communication between them.

With this in mind, deploy the Calico operator using the kubectl CLI tool.

    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.5/manifests/tigera-operator.yaml
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.5/manifests/tigera-operator.yaml
Next, download Calico’s custom-resources file using the curl command

    #curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O
    curl https://raw.githubusercontent.com/projectcalico/calico/v3.31.5.0/manifests/custom-resources.yaml -O

Update the CIDR defined in the custom-resources file to match the pod's network.

    sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
Then create resources defined in the YAML file

    kubectl create -f custom-resources.yaml
At this point, the master node, which acts as the control plane, is the only node that is available in the cluster. To verify this, run the command:

    kubectl get nodes
# Step 9: Add worker nodes to the cluster (on worker nodes)
With the master node configured, the remaining step is to add the worker nodes to the cluster. To do this, run the kubeadm join command generated in Step 7 when initializing the cluster.

So head back to the worker nodes and run the kubeadm join command below in each node.

    kubeadm join 84.32.214.62:6443 --token 2i5iru.f4m1vbxyc9w2ve7q \
            --discovery-token-ca-cert-hash sha256:29edadbccfc479ca35d1480058069dcadf7f694e510756fd153e4f65ae7f39f8
Now check the nodes in the cluster once again. This time around, you will see the worker nodes have joined the cluster.

    kubectl get nodes

# MetalLB Installation by manifest
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
# Next create
    vi metallb-configmap.yaml
    chmod +x metallb-configmap.yaml
    chown -Rv ibos:ibos metallb-configmap.yaml
# set the ip range
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: default-pool
      namespace: metallb-system
    spec:
      addresses:
      - 10.209.99.142-10.209.99.143
    ---
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
      name: l2
      namespace: metallb-system
    spec: {}

# apply
    kubectl apply -f metallb-configmap.yaml
# Verify pods
    kubectl get pods -n metallb-system
# Next critical check: Is your config applied
    kubectl get ipaddresspool -n metallb-system
    kubectl get l2advertisement -n metallb-system

# install Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
    chmod 700 get_helm.sh
    ./get_helm.sh
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
# Add Helm Repo in production namespace
    kubectl create namespace production
# Set Default Namespace for Current Context
    kubectl config set-context --current --namespace=production
    helm -n production repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm -n production repo add  stable https://charts.helm.sh/stable
	helm repo add nginx-stable https://helm.nginx.com/stable
	helm -n production  repo update
# Install Nginx Ingress Controller using Helm
    helm -n production install ibosio-ingress nginx-stable/nginx-ingress \
      --set controller.service.type=LoadBalancer \
      --set controller.ingressClass.name=ibosio-ingress \
      --set controller.ingressClass.create=true \
      --set controller.ingressClass.setAsDefaultIngress=false

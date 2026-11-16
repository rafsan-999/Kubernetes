# Step 1: Check if metrics-server is installed
    kubectl -n kube-system get pods | grep metrics-server

# Step 2: Install metrics-server (if missing)
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Step 3: Edit metrics-server args
Sometimes, depending on your environment (like bare-metal, kubeadm, Docker Desktop, 
or certain cloud providers), the metrics-server needs --kubelet-insecure-tls to talk to kubelets.

    kubectl -n kube-system edit deployment metrics-server

## Find the args: section and add:
    - --kubelet-insecure-tls

# Step 4: Verify metrics-server is working
    kubectl get apiservices | grep metrics
You should see something like:
v1beta1.metrics.k8s.io   True    20s

# Then try again:
    kubectl -n staging top pod


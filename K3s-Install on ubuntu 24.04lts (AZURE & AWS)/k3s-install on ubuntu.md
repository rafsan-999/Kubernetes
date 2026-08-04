# Install production ready k3s onubuntu server
### K3S Quick Install Script
    curl -sfL https://get.k3s.io | sh -
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
### MetaLLB Native mode – a lightweight deployment with the built-in native BGP implementation (no BFD, no IPv6 BGP). Suitable for L2-only or simple BGP setups:
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.16.1/config/manifests/metallb-native.yaml
### Create metallb-configmap.yaml
    vi metallb-configmap.yaml

### YAML File
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
    name: local-network-pool
    namespace: metallb-system
    spec:
    addresses:
        - 172.26.15.168-172.26.15.168
    ---
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
    name: local-network-advertisement
    namespace: metallb-system
    spec:
    ipAddressPools:
        - local-network-pool

### Apply
    apply -f metallb-configmap.yaml
### Install helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
    chmod 700 get_helm.sh
    ./get_helm.sh

    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
### Install Ingress-nginx
    kubectl create namespace production
    helm -n production repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm -n production repo add  stable https://charts.helm.sh/stable
    helm repo add nginx-stable https://helm.nginx.com/stable
    helm -n production  repo update
### Create ingressClass
    helm -n production install rafsan-ingress-class nginx-stable/nginx-ingress   --set controller.service.type=LoadBalancer   --set controller.ingressClass.name=rafsan-ingress-class   --set controller.ingressClass.create=true   --set controller.ingressClass.setAsDefaultIngress=false
### Create Secret TLS for specific Domain
    kubectl -n production create secret tls rafsan-tls   --cert=rafsan_cert_chain.pem   --key=rafsan_key.pem
### Create Docker registry
    kubectl -n production create secret docker-registry dockercred   --docker-server='https://index.docker.io/v1/'   --docker-username='rafsan'   --docker-password='Hkm*9l48@P#'   --docker-email='rafsan@gmail.com'
### Now Create a rafsan-ingress.yaml
    vi rafsan-ingress.yaml
### YAML File
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
    name: rafsan-ingress
    namespace: production
    annotations:
        nginx.ingress.kubernetes.io/configuration-snippet: |
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        proxy_buffering off;
        #nginx.ingress.kubernetes.io/rewrite-target: /$2
        #nginx.ingress.kubernetes.io/use-regex: "true"
        nginx.ingress.kubernetes.io/cors-allow-credentials: "true"
        nginx.ingress.kubernetes.io/cors-allow-headers: Authorization, Content-Type
        nginx.ingress.kubernetes.io/cors-allow-methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
        nginx.ingress.kubernetes.io/enable-cors: "true"
        nginx.ingress.kubernetes.io/enable-websockets: "true"
        nginx.ingress.kubernetes.io/proxy-body-size: 100m
        nginx.ingress.kubernetes.io/proxy-buffering: "off"
        nginx.ingress.kubernetes.io/proxy-read-timeout: "86400"
        nginx.ingress.kubernetes.io/proxy-send-timeout: "86400"
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
        nginx.org/client-max-body-size: "100m"
        nginx.ingress.kubernetes.io/proxy-request-buffering: "off"
        #nginx.ingress.kubernetes.io/upstream-hash-by: $arg_access_token
        #nginx.org/websocket-services: "rafsan-notification-management-api"
    spec:
    ingressClassName: rafsan-ingress-class
    rules:
        - host: k3s-test.rafsan.io
        http:
            paths:
            - path: /
            pathType: Prefix
            backend:
                service:
                name: jasfare-b2b-panel-frontend
                port:
                    number: 80
        - host: test-api.rafsan.io
        http:
            paths:
            - path: /sabre
            pathType: Prefix
            backend:
                service:
                name: test-sabre
                port:
                    number: 80
            - path: /air-master
            pathType: Prefix
            backend:
                service:
                name: test-airmaster
                port:
                    number: 80
            - path: /reservation-management
            pathType: Prefix
            backend:
                service:
                name: test-reservation-management-api
                port:
                    number: 80
    tls:
        - hosts:
            - k3s-test.rafsan.io
            - test-api.rafsan.io
        secretName: rafsan-tls
# Apply yaml file
kubectl -n production apply -f rafsan-ingress.yaml

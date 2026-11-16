# Kubernetes Gateway API

### What is Kubernetes Gateway API?
As the name suggests, the Gateway API is a Kubernetes feature that helps create gateways for external traffic entering your cluster.But if Ingress already does that, why do we need something new?
Ingress is the traffic routing mechanism primarily used in Kubernetes environments. However, it comes with several limitations. For example,

It supports only host and path-based routing for HTTP/HTTPS (Layer 7).
Cross-namespace routing is complex and not straightforward.
Relies heavily on annotations for anything beyond basic routing
and more..
So, to overcome all the Ingress limitations, the Kubernetes Gateway API was developed.

### The Gateway API has the following key features.

1. Gateway API can perform L4 and L7 routing based on HTTP, gRPC, or TCP/UDP (experimental)
2. Can route traffic based on HTTP headers.
3. Can perform cross-namespace routing.
4. Supports weighted traffic routing, blue-green deployments, canary deployments, and more.
5. Reduced reliance on vendor-specific controller annotations, making configurations more portable across environments.
6. Gateway API also works well with service mesh integrations such as Istio, Linkerd, etc.
In summary, the Gateway API is an improved version of Kubernetes Ingress that offers more powerful and flexible traffic management.

So if you already have a solid understanding of Kubernetes Ingress, Ingress Controllers, and their limitations, picking up the Gateway API concepts is easier

# Gateway API Controller
In Ingress controllers, we define routing rules in the Ingress object. The Ingress Controller handles the actual routing.
The same concept applies to the Gateway API.

While the Gateway API provides many objects to manage cluster traffic, the actual routing is done by a Gateway API Controller. This controller is not built into Kubernetes. You need to set up a third-party (vendor) controller, just like with Ingress.
Various Gateway API controllers are available. The following are some of the popular ones.

1. Envoy Gateway
2. Traefik Gateway
3. Nginx Gateway Fabric
4. Kong Gateway

# Setup Prerequisites
The following are the requirements for the setup
1. Kubernetes Cluster v1.30 or higher.
2. Helm [Local Machine]
3. Kubectl [Local Machine]
We can begin the installation from the Gateway API.

# Setup Gateway API in the Kubernetes Cluster
1. Gateway API CRD installation
2. Gateway API controller installation
3. Gateway API object creation and traffic validation

# Step 1: Install Gateway API CRDs
To install the Gateway API CRDs, use the following command. To get the latest version of the CRD, please visit this page. At the time of updating this guide, v1.3.0 is the latest version.

    kubectl -n staging apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
validate the installed CRDs using the following command

    kubectl -n staging get crds | grep gateway
You can also check the API resources to get more details about the registered CRDs.

    kubectl -n staging api-resources --api-group=gateway.networking.k8s.io
### Install Envoy Gateway
    helm -n staging install envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
      -n envoy-gateway-system --create-namespace
### Check pods
    kubectl -n staging get pods -n envoy-gateway-system
### Create a basic Gateway
    apiVersion: gateway.networking.k8s.io/v1
    kind: Gateway
    metadata:
      name: main-gateway
      namespace: default
    spec:
      gatewayClassName: envoy
      listeners:
      - name: http
        port: 80
        protocol: HTTP
        allowedRoutes:
          namespaces:
            from: All
### Apply
    kubectl apply -f gateway.yaml
### Verify Gateway
    kubectl get gateway
### Manually create GatewayClass
    apiVersion: gateway.networking.k8s.io/v1
    kind: GatewayClass
    metadata:
      name: envoy
    spec:
      controllerName: gateway.envoyproxy.io/gatewayclass-controller
### Apply
    kubectl apply -f gatewayclass.yaml
### check
    kubectl get gatewayclasses
### Create HTTPRoute
    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: peopledesk-front-route
    spec:
      parentRefs:
      - name: main-gateway
    
      hostnames:
      - devtest.ibos.io
    
      rules:
      - matches:
        - path:
            type: PathPrefix
            value: /
    
        backendRefs:
        - name: peopledesk-matador-front
          port: 80
### Apply
    kubectl apply -f route.yaml
    kubectl get httproute

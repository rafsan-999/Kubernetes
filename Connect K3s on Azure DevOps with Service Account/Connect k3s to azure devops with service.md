# Connect k3s to azure devops with service account

### Create or Edit the K3s API certificate with the public IP
    sudo nano /etc/rancher/k3s/config.yaml
### If you also have a DNS name (recommended), include it too:
    tls-san:
      - 47.*.*.18
      - k3s.ibos.io
### Restart K3s
    systemctl restart k3s
### Create a namespace
    kubectl create namespace production
### Create a ServiceAccount
    kubectl create serviceaccount azure-devops -n production
### Verify
    kubectl get sa -n production
### Create a token using yaml file
    vi azure-devops-access.yaml

    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: azure-devops
      namespace: production
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: azure-devops-cluster-admin
    subjects:
      - kind: ServiceAccount
        name: azure-devops
        namespace: production
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: azure-devops-token
      namespace: production
      annotations:
        kubernetes.io/service-account.name: azure-devops
    type: kubernetes.io/service-account-token

### apply this azure-devops-access.yaml
kubectl -n production apply -f azure-devops-access.yaml
### Verify
    openssl s_client -connect 47.*.*.18:6443 -showcerts </dev/null \
| openssl x509 -noout -text | grep -A2 "Subject Alternative Name"
### For Server url
    kubectl config view --minify -o jsonpath={.clusters[0].cluster.server}

###  Use the output from this command below and paste to the azure DevOps secret field
    kubectl get secret azure-devops-token -n production -o json

    {
        "apiVersion": "v1",
        "data": {
            "ca.crt": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJlRENDQVIyZ0F3SUJBZ0lCQURBS0JnZ3Foa2pPUFFRREFqQWpNU0V3SHdZRFZRUUREQmhyTTNNdGMyVnkKZG1WeUxXTmhRREUzT0RVM016YzVNREl3SGhjTk1qWXdPREF6TURVeE9ESXlXaGNOTXpZd056TXhNRFV4T0RJeQpXakFqTVNFd0h3WURWUVFEREJock0zTXRjMlZ5ZG1WeUxXTmhRREUzT0RVM016YzVNREl3V1RBVEJnY3Foa2pPClBRSUJCZ2dxaGtqT1BRTUJCd05DQUFRbHRIUUNDU2xPUCt4cHhWQnpoZ1FoK2RmUS8vRitBTVZnZmd2ZUcvaEoKVGROcy9DR0V4MVZVdW1wNWN5NkxNUFpsbi9kV2lXNnhZc1hDMGI4TkFSUjJvMEl3UURBT0JnTlZIUThCQWY4RQpCQU1DQXFRd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVSt2YnhjdURJOHNjN1VrYVBDYzFjCkZFSlFpMWt3Q2dZSUtvWkl6ajBFQXdJRFNRQXdSZ0loQU1aNVB2T3dvdVA2Z21QVmtueEJId0FRVmZJMWZBUXMKZjBRRkt6Z21SSHVCQWlFQW50MlhIQ0VuRFVPMFphaG9qeFlnRm85QlJtQUhpVy9RZlJ1SmZaUWZ1UW89Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
            "namespace": "cHJvZHVjdGlvbg==",
            "token": "ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkltdExhSGh2TmtKaFlubHZlbTlyWWxoNVlVVndUbWRNWkVKck1FOXFjbHBFT0doU00zazNiMkZKZGtVaWZRLmV5SnBjM01pT2lKcmRXSmxjbTVsZEdWekwzTmxjblpwWTJWaFkyTnZkVzUwSWl3aWEzVmlaWEp1WlhSbGN5NXBieTl6WlhKMmFXTmxZV05qYjNWdWRDOXVZVzFsYzNCaFkyVWlPaUp3Y205a2RXTjBhVzl1SWl3aWEzVmlaWEp1WlhSbGN5NXBieTl6WlhKMmFXTmxZV05qYjNWdWRDOXpaV055WlhRdWJtRnRaU0k2SW1GNmRYSmxMV1JsZG05d2N5MTBiMnRsYmlJc0ltdDFZbVZ5Ym1WMFpYTXVhVzh2YzJWeWRtbGpaV0ZqWTI5MWJuUXZjMlZ5ZG1salpTMWhZMk52ZFc1MExtNWhiV1VpT2lKaGVuVnlaUzFrWlhadmNITWlMQ0pyZFdKbGNtNWxkR1Z6TG1sdkwzTmxjblpwWTJWaFkyTnZkVzUwTDNObGNuWnBZMlV0WVdOamIzVnVkQzUxYVdRaU9pSm1OREF3WkdJNE1DMWpNRGd3TFRSaVpXRXRZV1F6TWkwNU4yUTNPVEJrTUdObVkyWWlMQ0p6ZFdJaU9pSnplWE4wWlcwNmMyVnlkbWxqWldGalkyOTFiblE2Y0hKdlpIVmpkR2x2YmpwaGVuVnlaUzFrWlhadmNITWlmUS5JbEFZVTdxZm1qaGp6RnB0aVVwZzN6Y2g2aklVMU41S19BZU56amlkOFY0QWdXNENoc2N0LTJxblNnZGxkTUVheEcybVRrUUR0ZllZdHRobWp2M00xQkNfX3kwdFJKeWpkUTB3dFlUTW9qLUVGMUNqMTNYcmJTd3pwOThFRXNCSEpMTFMxa2RmYmhwX25HTHZJQlZJZXZjQXlnZFF4NjEzZjFNMzNVRk8zMVhId0VlRkVDaHNvZ1JEdVhiSGQzUVI0MjgyLWpUN3ZfX0NEVFpXSlozbHBodzdPeDZZMlNhVGl1NjFlNC1adGNaR2xrT2RoUG1aYVVDZ2tQU0RiS0p4eUJmU2ZLSnhSbHk0TjNNdXpZRmZSWUlsSUJ1X3BXZUhBd3VXeFpEdTIzTTcyS0o3ZEJKMmdEbEFHa0d1MW5BX0s3Z3ktaEdEb2ZSSzIzRUxLbTctRGc="
        },
        "kind": "Secret",
        "metadata": {
            "annotations": {
                "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"v1\",\"kind\":\"Secret\",\"metadata\":{\"annotations\":{\"kubernetes.io/service-account.name\":\"azure-devops\"},\"name\":\"azure-devops-token\",\"namespace\":\"production\"},\"type\":\"kubernetes.io/service-account-token\"}\n",
                "kubernetes.io/service-account.name": "azure-devops",
                "kubernetes.io/service-account.uid": "f400db80-c080-4bea-ad32-97d790d0cfcf"
            },
            "creationTimestamp": "2026-08-03T08:09:27Z",
            "labels": {
                "kubernetes.io/legacy-token-last-used": "2026-08-03"
            },
            "name": "azure-devops-token",
            "namespace": "production",
            "resourceVersion": "4515",
            "uid": "2756c11f-799e-438d-9da2-13535bdfdb06"
        },
        "type": "kubernetes.io/service-account-token"
    }

### Disable Traefik permanently from k3s
    kubectl -n kube-system get helmchart
    kubectl -n kube-system delete helmchart traefik
    kubectl -n kube-system delete svc traefik

### Create or edit the K3s config
    sudo nano /etc/rancher/k3s/config.yaml
    
    disable:
      - traefik
      - servicelb
### restart k3s
    systemctl restart k3s

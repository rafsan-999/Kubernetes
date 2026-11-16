#ARL-Ingress
kubectl get configmap -n production
kubectl patch configmap arl-ingress-nginx-ingress -n production   --type merge -p '{"data":{"http2":"true"}}'
kubectl rollout restart deployment arl-ingress-nginx-ingress-controller -n production
kubectl rollout status deployment arl-ingress-nginx-ingress-controller -n production
#http2 Check
curl -I --http2 https://erp.ibos.io
#Result
HTTP/2 200
server: nginx/1.25.3
date: Wed, 11 Mar 2026 07:38:52 GMT
content-type: text/html
content-length: 7437
last-modified: Wed, 11 Mar 2026 06:30:18 GMT
vary: Accept-Encoding
etag: "69b10bfa-1d0d"
cache-control: no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0
accept-ranges: bytes



#Managerium-ingress
kubectl get configmap -n production
kubectl patch configmap managerium-ingress-nginx-ingress -n production   --type merge -p '{"data":{"http2":"true"}}'
kubectl rollout restart deployment managerium-ingress-nginx-ingress-controller -n production
kubectl rollout status deployment managerium-ingress-nginx-ingress-controller -n production
#http2 Check


#Peopledesk-ingress-nginx-ingress
kubectl get configmap -n production
kubectl patch configmap peopledesk-ingress-nginx-ingress -n production   --type merge -p '{"data":{"http2":"true"}}'
kubectl rollout restart deployment peopledesk-ingress-nginx-ingress-controller -n production
kubectl rollout status deployment peopledesk-ingress-nginx-ingress-controller -n production
#http2 Check
curl -I --http2 https://app.peopledesk.io

#For Managerium Kubernetes
kubectl get configmap -n production
kubectl patch configmap mgm-ingress-nginx-ingress -n production   --type merge -p '{"data":{"http2":"true"}}'
kubectl rollout restart deployment mgm-ingress-nginx-ingress-controller -n production
kubectl rollout status deployment mgm-ingress-nginx-ingress-controller -n production
#http2 Check
curl -I --http2 https://mgm.ibos.io
#Result
HTTP/2 200
server: nginx/1.27.1
date: Wed, 11 Mar 2026 07:37:39 GMT
content-type: text/html
content-length: 1710
vary: Accept-Encoding
etag: "69ad4597-6ae"
last-modified: Wednesday, 11-Mar-2026 07:37:39 UTC
cache-control: no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0
strict-transport-security: max-age=31536000; includeSubDomains; preload
x-xss-protection: 1; mode=block
x-frame-options: DENY
x-content-type-options: nosniff
referrer-policy: same-origin
x-permitted-cross-domain-policies: master-only
accept-ranges: bytes


# USA-POS-ingress-nginx-ingress
kubectl get configmap -n production
kubectl patch configmap usa-pos-ingress-nginx-ingress -n production   --type merge -p '{"data":{"http2":"true"}}'
kubectl rollout restart deployment usa-pos-ingress-nginx-ingress-controller -n production
kubectl rollout status deployment usa-pos-ingress-nginx-ingress-controller -n production
#http2 Check
curl -I --http2 https://usapos.ibos.io
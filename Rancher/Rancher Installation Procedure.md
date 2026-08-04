# Installation Procedure
Install Docker

#### Create Persistent Docker Volume
    docker volume create rancher-data
    docker volume inspect rancher-data

#### Run Rancher Container
    docker run -d \
    --name rancher \
    --restart unless-stopped \
    --privileged \
    -p 10.209.99.36:8080:80 \
    -p 10.209.99.36:8443:443 \
    -v rancher-data:/var/lib/rancher \
    rancher/rancher:latest

#### Verify Startup
    docker ps --filter name=rancher
    docker logs --tail 100 rancher
    curl -k https://10.209.99.191:8443/ping


    docker run -d \
    --name rancher \
    --restart unless-stopped \
    --privileged \
    -p 10.209.99.36:8080:80 \
    -p 10.209.99.36:8443:443 \
    -v rancher-data:/var/lib/rancher \
    rancher/rancher:latest
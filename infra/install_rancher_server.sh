#!/bin/bash -e

which docker || curl https://releases.rancher.com/install-docker/1.12.sh | sh
mkdir -p /var/lib/mysql
docker run --name rancher_server -d -v /var/lib/mysql:/var/lib/mysql --restart=unless-stopped -p 8080:8080 rancher/server

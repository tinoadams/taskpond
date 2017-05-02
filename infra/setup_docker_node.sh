#!/bin/bash -e

function usage() {
    echo "Usage: $0 REMOTE_HOST"
    exit 255
}

function error() {
    >&2 echo $1
    exit 2
}

[ ! -z "$1" ] && REMOTE_HOST=$1 || usage

pushd `dirname $0`

echo "Copying pub-key to remote host..."
ssh-copy-id root@${REMOTE_HOST}

echo "Updating OS..."
# ssh root@${REMOTE_HOST} 'yum update -y && yum clean all'
ssh root@${REMOTE_HOST} 'bash -s' < ubuntu_kernel.sh
# ssh root@${REMOTE_HOST} 'apt-get update -y && apt-get upgrade -y'


# echo "Installing Docker..."
# ssh root@${REMOTE_HOST} 'bash -s' < install_docker.sh

# echo "Deploying flanneld..."
# ssh root@${REMOTE_HOST} 'ls /usr/local/bin/flanneld || curl -o /usr/local/bin/flanneld -L "https://github.com/coreos/flannel/releases/download/v0.6.2/flanneld-amd64" && chmod 0744 /usr/local/bin/flanneld'

# echo "Installing etcd..."
# ssh root@${REMOTE_HOST} 'apt-get install -y etcd=2.2.5+dfsg-1'

# ssh root@${REMOTE_HOST} 'apt-get install -y bridge-utils'

# echo "Installing Kubernetes Master..."
# ssh root@${REMOTE_HOST} 'bash -s' < setup_k8s_master.sh

#!/bin/bash -e

function usage() {
    echo "Usage: $0 REMOTE_HOST [DEPLOYER_KEY_FILE]"
    exit 255
}

function error() {
    >&2 echo $1
    exit 2
}

[ ! -z "$1" ] && REMOTE_HOST=$1 || usage
[ ! -z "$2" ] && DEPLOYER_KEY_FILE=$2 || DEPLOYER_KEY_FILE=/home/vagrant/.ssh/deployer
REMOTE_USER=root

function runCmdOnRemoteHost() {
    ssh -i ${DEPLOYER_KEY_FILE} ${REMOTE_USER}@${REMOTE_HOST} "$1"
}

function runScriptOnRemoteHost() {
    ssh -i ${DEPLOYER_KEY_FILE} ${REMOTE_USER}@${REMOTE_HOST} 'bash -s' < $1
}

pushd `dirname $0`

echo "Copying pub-key to remote host..."
ssh-copy-id -i ${DEPLOYER_KEY_FILE}.pub ${REMOTE_USER}@${REMOTE_HOST}

echo "Updating OS..."
runCmdOnRemoteHost 'apt-get update && apt-get upgrade -y'
# # # ssh 'yum update -y && yum clean all'
# # runScriptOnRemoteHost ubuntu_kernel.sh

echo "Installing Rancher..."
runScriptOnRemoteHost install_rancher_server.sh

# echo "Installing Docker..."
# runScriptOnRemoteHost install_docker.sh

# echo "Deploying flanneld..."
# ssh 'ls /usr/local/bin/flanneld || curl -o /usr/local/bin/flanneld -L "https://github.com/coreos/flannel/releases/download/v0.6.2/flanneld-amd64" && chmod 0744 /usr/local/bin/flanneld'

# echo "Installing etcd..."
# ssh 'apt-get install -y etcd=2.2.5+dfsg-1'

# ssh 'apt-get install -y bridge-utils'

# echo "Installing Kubernetes Master..."
# runScriptOnRemoteHost setup_k8s_master.sh

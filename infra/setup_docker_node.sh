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

echo "Installing Docker..."
ssh root@${REMOTE_HOST} 'bash -s' < install_docker.sh

echo "Preparing Flannel..."
if [ ! -f flannel/dist/flanneld-amd64 ]; then
    [ -d flannel ] || git clone --branch v0.5.6 --single-branch --depth 1 https://github.com/coreos/flannel.git
    cp -f Flannel.Makefile flannel/Makefile
    pushd flannel
    echo "Building Flannel..."
    make dist/iptables-amd64
    make dist/flanneld-amd64
    popd
fi
echo "Deploying flanneld..."
scp flannel/dist/flanneld-amd64 root@${REMOTE_HOST}:/usr/local/bin/

echo "Installing etcd..."
ssh root@${REMOTE_HOST} 'apt-get install -y etcd=2.2.5+dfsg-1'


ssh root@${REMOTE_HOST} 'apt-get install -y bridge-utils'

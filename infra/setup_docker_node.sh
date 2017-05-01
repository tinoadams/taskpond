#!/bin/bash

function usage() {
    echo "Usage: $0 REMOTE_HOST"
    exit 255
}

function error() {
    >&2 echo $1
    exit 2
}

[ ! -z "$1" ] && REMOTE_HOST=$1 || usage

echo "Copying PUB key to remote host..."
ssh-copy-id root@${REMOTE_HOST}
echo "Installing Docker..."
ssh root@${REMOTE_HOST} 'bash -s' < <(curl -s https://gist.githubusercontent.com/cr0hn/68643930f8b5ae293f9cfc5c5f495d29/raw/eca7367462d7d63cdf930fe12136ad4ff159ae90/install_docker_ubuntu.sh)

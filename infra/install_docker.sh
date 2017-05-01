#!/bin/bash -e

#sudo apt-get -y install apt-transport-https ca-certificates
#sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
#echo deb https://apt.dockerproject.org/repo ubuntu-xenial main > /etc/apt/sources.list.d/docker.list 
#sudo apt-get update -y
#sudo apt-get purge -y lxc-docker
#sudo apt-get install -y docker-engine=1.12.6-0~ubuntu-xenial
#sudo service docker start
#init 6
#
#exit 0

echo "Setting up Docker repo..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "Installing Docker..."
sudo apt-get update -y
sudo apt-get install docker-ce=17.03.0~ce-0~ubuntu-xenial

echo "Starting Docker..."
sudo service docker start

#!/bin/bash

####################################################################
# Made by Erget Kabaj                                              #
# This is a script to automate Docker and docker compose and build #
# an image also build an docker composer                           #
####################################################################

set -e

echo "Downloading Docker and installing it"

echo "Removing any Packages that may be residual in the system"

sudo apt-get remove docker \
                    docker-engine \
                    docker.io \
                    containerd \
                    runc

echo "Updating the System"

sudo apt-get update

sudo apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

echo "Add Docker’s official GPG key"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install \
                docker-ce \
                docker-ce-cli \
                containerd.io


echo "Starting Docker"

systemctl start docker
systemctl enable docker

echo "testting if docker is installed correctly"

test_run=docker run hello-world
echo $test_run

if [[ $test_run == $(echo ?)]]


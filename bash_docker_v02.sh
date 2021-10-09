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

echo "Testting if docker is installed correctly"

test=$(systemctl status docker)
stats=$(echo $?)

if [[  $stats == 0 ]]
then
    echo "Docker running"
else
    echo "Docker not running"
    exit 1
fi

echo "Building an docker image "

mkdir $HOME/docker_test && cd $HOME/docker_test
git clone https://github.com/remy/html5demos.git

cat << EOF > Dockerfile
FROM httpd:latest
COPY ./html5demos/www/ /usr/local/apache2/htdocs/
EXPOSE 80
EOF

docker build -t httd_test:v01 .

docker run -d -p 80:80 httd_test:v01

echo "Test if the build and the run are succeslfully"

test_run=$(docker ps | awk {'print $2'} | grep httd_test:v01)

if [[ $test_run = "httd_test:v01" ]]
then
    echo "Build Succesfull"
    echo "Go to localhost:80 to see the webpage"
else
    echo "Not Succesfull check the build"
    exit 1
fi

echo "Creating the Composer file"

cat << EOF > docker-compose.yml
version: "3.7"
services:
  httpd:
    build: . 
    ports: 
      - 81:80
  nginx:
    image: nginx:latest
    volumes: 
      - ./html5demos/www/:/usr/share/nginx/html
    ports: 
      - 82:80

EOF

docker-compose build && docker-compose up -d

test_run_httpd=$(docker ps | awk {'print $2'} | grep docker_test_httpd)
STATS=$(echo $?)

if [[ $test_run_httpd = "docker_test_httpd" ]]
then
    echo "Build Succesfull"
    echo "Go to localhost:81 to see the HTTP webpage build by docker compose"
else
    echo "Not Succesfull check the build"
    exit 1
fi

test_run_nginx=$(docker ps | awk {'print $2'} | grep nginx:latest)
STATS=$(echo $?)

if [[ $test_run_nginx = "nginx:latest" ]]
then
    echo "Build Succesfull"
    echo "Go to localhost:82 to see the NGINX webpage build by docker compose"
else
    echo "Not Succesfull check the build"
    exit 1
fi
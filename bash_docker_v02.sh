
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
COPY ./html5demos/ /usr/local/apache2/htdocs/
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
    build: httd_test:v01
    expose: 
      - 81:80
  nginx:
    image: nginx:latest
    volumes: 
      - /html5demos/www/:/usr/share/nginx/html
    expose: 
      - 82:80
volumes:
  /html5demos/www/
EOF

docker-compose build && docker-compose up -d

test_run_httpd=$(docker ps | awk {'print $2'} | grep httd_test:v01)
STATS=$(echo $?)

if [[ $test_run_httpd = "httd_test:v01" ]]
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

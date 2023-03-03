#!/bin/bash

show_usage (){
    printf "Usage: $0 [options [parameters]]\n"
    printf "\n"
    printf "Options:\n"
    printf " -d|--domain, enter domain name\n"
    printf " -s|--service enter service name\n"
    printf " -b|--subdomain, enter subdomain name\n"
    printf " -i|--image, enter image name\n"
    printf " -p|--port, enter port number\n"
    printf " -h|--help, show usage\n"
return 0
}


if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]];then
    show_usage
else
    echo "Incorrect input provided"
    show_usage
fi


while [ ! -z "$1" ]; do
  case "$1" in
     --service|-s)
         shift
         echo "You entered service name as: $1"
         SERVICE_NAME="$1"
         ;;
     --domain|-d)
         shift
         echo "You entered domain as: $1"
         DOMAIN_NAME="$1"
         ;;
     --image|-i)
         shift
         echo "You entered image as: $1"
         IMAGE_NAME="$1"
         ;;
     --port|-p)
         shift
         echo "You entered port as: $1"
         PORT="$1"
         ;;    
     --subdomain|-b)
        shift
        echo "You entered sybdomain as: $1"
        SUBDOMAIN_NAME="$1"
         ;;
     *)
        show_usage
        ;;
  esac
shift
done
while true; do
    read -p "Do you wish to install this program? " yn
    case $yn in
        [Yy]* )  

        if [ -x "$(command -v docker)" ]; then
            echo "DOCKER IS ALREADY INSTALLED...!"
          else
            echo "Installing docker..."
            # command
            sudo apt update
            sudo apt --yes --no-install-recommends install apt-transport-https ca-certificates
            wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
            sudo apt update
            sudo apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
            sudo usermod --append --groups docker "$USER"
            sudo chmod 666 /var/run/docker.sock
            sudo systemctl enable docker
            printf '\nDocker installed successfully\n\n'

            printf 'Waiting for Docker to start...\n\n'
            sleep 5
        fi

        if docker-compose --version ; then
            echo "DOCKER-COMPOSE IS ALREADY INSTALLED...!"
          else
            echo "Installing docker compose..."
            # command
            sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
            printf '\nDocker Compose installed successfully\n\n'
        fi

        sudo service docker start

        DOCKER_NETWORK_NAME="traefik-net"

        if [ ! "$(docker network ls | grep $DOCKER_NETWORK_NAME)" ]; then
          echo "Creating $DOCKER_NETWORK_NAME network ..."
          docker network create --driver bridge $DOCKER_NETWORK_NAME
        else
          echo "$DOCKER_NETWORK_NAME network exists."
        fi

        mkdir traefik
        mkdir traefik/traefik_data
        touch traefik/traefik_data/acme.json
        chmod 600 traefik/traefik_data/acme.json
        echo 'debug = true' >> traefik/traefik_data/traefik.toml
        echo 'logLevel = "DEBUG"' >> traefik/traefik_data/traefik.toml
        echo 'defaultEntryPoints = ["https","http"]' >> traefik/traefik_data/traefik.toml
        echo ' ' >> traefik/traefik_data/traefik.toml
        echo '[entryPoints]' >> traefik/traefik_data/traefik.toml
        echo '  [entryPoints.web]' >> traefik/traefik_data/traefik.toml
        echo '    address = ":80"' >> traefik/traefik_data/traefik.toml
        echo '    [entryPoints.web.http.redirections]' >> traefik/traefik_data/traefik.toml
        echo '      [entryPoints.web.http.redirections.entryPoint]' >> traefik/traefik_data/traefik.toml
        echo '        to = "websecure"' >> traefik/traefik_data/traefik.toml
        echo '  [entryPoints.websecure]' >> traefik/traefik_data/traefik.toml
        echo '    address = ":443"' >> traefik/traefik_data/traefik.toml
        echo '  ' >> traefik/traefik_data/traefik.toml
        echo '[api]' >> traefik/traefik_data/traefik.toml
        echo '  dashboard = true' >> traefik/traefik_data/traefik.toml
        echo '  insecure = true' >> traefik/traefik_data/traefik.toml
        echo ' '  >> traefik/traefik_data/traefik.toml
        echo '[providers.docker]' >> traefik/traefik_data/traefik.toml
        echo 'endpoint = "unix:///var/run/docker.sock"' >> traefik/traefik_data/traefik.toml
        echo 'watch = true' >> traefik/traefik_data/traefik.toml
        echo 'exposedbydefault = false' >> traefik/traefik_data/traefik.toml
        echo 'network = "$DOCKER_NETWORK_NAME"' >> traefik/traefik_data/traefik.toml
        echo '  ' >> traefik/traefik_data/traefik.toml
        echo '   ' >> traefik/traefik_data/traefik.toml
        echo '[certificatesResolvers.lets-encrypt.acme]' >> traefik/traefik_data/traefik.toml
        echo '  email = "fenilnakrani64@gmail.com"' >> traefik/traefik_data/traefik.toml
        echo '  storage = "acme.json"' >> traefik/traefik_data/traefik.toml
        echo '  [certificatesResolvers.lets-encrypt.acme.httpChallenge]' >> traefik/traefik_data/traefik.toml
        echo '      entrypoint = "web"' >> traefik/traefik_data/traefik.toml


        echo 'version: "3"' >>traefik/docker-compose.yml
        echo '  ' >>traefik/docker-compose.yml
        echo 'services: ' >>traefik/docker-compose.yml
        echo '  traefik:' >>traefik/docker-compose.yml
        echo '    image: traefik:v2.5' >>traefik/docker-compose.yml
        echo '    container_name: traefik' >>traefik/docker-compose.yml
        echo '    restart: always' >>traefik/docker-compose.yml
        echo '    ports:' >>traefik/docker-compose.yml
        echo '      - 80:80' >>traefik/docker-compose.yml
        echo '      - 443:443' >>traefik/docker-compose.yml
        echo '    volumes:' >>traefik/docker-compose.yml
        echo '      - /var/run/docker.sock:/var/run/docker.sock' >>traefik/docker-compose.yml
        echo '      - ./traefik_data/traefik.toml:/traefik.toml' >>traefik/docker-compose.yml
        echo '      - ./traefik_data/acme.json:/acme.json' >>traefik/docker-compose.yml
        echo '    networks:' >>traefik/docker-compose.yml
        printf "      - %s\n" $DOCKER_NETWORK_NAME >>traefik/docker-compose.yml
        echo '  ' >>traefik/docker-compose.yml
        echo 'networks:' >>traefik/docker-compose.yml

        printf "  %s:\n" $DOCKER_NETWORK_NAME >>traefik/docker-compose.yml
        echo '    external: true' >>traefik/docker-compose.yml

        cd traefik
        docker-compose up -d
        cd
        mkdir $SERVICE_NAME

                echo "got service name = $SERVICE_NAME"
        shift "$(($OPTIND -1))"
        mkdir $SERVICE_NAME
        echo 'version: "3"' >>$SERVICE_NAME/docker-compose.yml
        echo 'services:' >>$SERVICE_NAME/docker-compose.yml
        echo '  '$SERVICE_NAME':' >>$SERVICE_NAME/docker-compose.yml
        echo '    image: '$IMAGE_NAME':latest'>>$SERVICE_NAME/docker-compose.yml
        echo '    container_name: '$SERVICE_NAME''>>$SERVICE_NAME/docker-compose.yml
        echo '    restart: unless-stopped'>>$SERVICE_NAME/docker-compose.yml
        echo '    volumes:'>>$SERVICE_NAME/docker-compose.yml
        echo '      - '$SERVICE_NAME'_data:/data'>>$SERVICE_NAME/docker-compose.yml
        echo '    networks:'>>$SERVICE_NAME/docker-compose.yml
        echo '      - traefik-net'>>$SERVICE_NAME/docker-compose.yml
        echo '    ports:'>>$SERVICE_NAME/docker-compose.yml
        echo '      - '$PORT':'$PORT''>>$SERVICE_NAME/docker-compose.yml
        echo '    labels:'>>$SERVICE_NAME/docker-compose.yml
        echo '      - "traefik.enable=true"'>>$SERVICE_NAME/docker-compose.yml
        echo '      - "traefik.http.routers.'$SERVICE_NAME'.rule=Host(`'$SUBDOMAIN_NAME'.'$DOMAIN_NAME'`)"'>>$SERVICE_NAME/docker-compose.yml
        echo '      - "traefik.http.services.'$SERVICE_NAME'.loadbalancer.server.port='$PORT'"'>>$SERVICE_NAME/docker-compose.yml
        echo '      - "traefik.http.routers.'$SERVICE_NAME'.tls.certresolver=lets-encrypt"'>>$SERVICE_NAME/docker-compose.yml
        echo '      - "traefik.http.routers.'$SERVICE_NAME'.tls=true"'>>$SERVICE_NAME/docker-compose.yml
        echo ' '>>$SERVICE_NAME/docker-compose.yml
        echo 'volumes:'>>$SERVICE_NAME/docker-compose.yml
        echo '  '$SERVICE_NAME'_data:'>>$SERVICE_NAME/docker-compose.yml
        echo '    external: true'>>$SERVICE_NAME/docker-compose.yml
        echo ' '>>$SERVICE_NAME/docker-compose.yml
        echo 'networks:'>>$SERVICE_NAME/docker-compose.yml
        echo '  traefik-net:'>>$SERVICE_NAME/docker-compose.yml
        echo '    external: true'>>$SERVICE_NAME/docker-compose.yml
        break;;

        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
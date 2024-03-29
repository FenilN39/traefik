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
echo 'network = "'$DOCKER_NETWORK_NAME'"' >> traefik/traefik_data/traefik.toml
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
echo '    image: traefik:latest' >>traefik/docker-compose.yml
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
docker compose up -d
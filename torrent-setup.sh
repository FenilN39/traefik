echo 'makind directory for qbittorrent'
mkdir -p qbittorrent
echo 'version: "2.1"'>> qbittorrent/docker-compose.yml
echo 'services:'>> qbittorrent/docker-compose.yml
echo '  qbittorrent:'>> qbittorrent/docker-compose.yml
echo '    image: lscr.io/linuxserver/qbittorrent:latest'>> qbittorrent/docker-compose.yml
echo '    container_name: qbittorrent'>> qbittorrent/docker-compose.yml
echo '    environment:'>> qbittorrent/docker-compose.yml
echo '      - PUID=1000'>> qbittorrent/docker-compose.yml
echo '      - PGID=1000'>> qbittorrent/docker-compose.yml
echo '      - TZ=Etc/UTC'>> qbittorrent/docker-compose.yml
echo '      - WEBUI_PORT=8080'>> qbittorrent/docker-compose.yml
echo '    volumes:'>> qbittorrent/docker-compose.yml
echo '      - ./appdata/config:/config'>> qbittorrent/docker-compose.yml
echo '      - ./downloads:/downloads'>> qbittorrent/docker-compose.yml
echo '    ports:'>> qbittorrent/docker-compose.yml
echo '      - 8080:8080'>> qbittorrent/docker-compose.yml
echo '      - 6881:6881'>> qbittorrent/docker-compose.yml
echo '      - 6881:6881/udp'>> qbittorrent/docker-compose.yml
echo '    restart: unless-stopped'>> qbittorrent/docker-compose.yml
echo '    networks:'>>qbittorrent/docker-compose.yml
echo '      - traefik-net'>>qbittorrent/docker-compose.yml
echo '    labels:'>>qbittorrent/docker-compose.yml
echo '      - "traefik.enable=true"'>>qbittorrent/docker-compose.yml
echo '      - "traefik.http.routers.qbittorrent.rule=Host(`sub.domain.com`)"'>>qbittorrent/docker-compose.yml
echo '      - "traefik.http.services.qbittorrent.loadbalancer.server.port=8080"'>>qbittorrent/docker-compose.yml
echo '      - "traefik.http.routers.qbittorrent.tls.certresolver=lets-encrypt"'>>qbittorrent/docker-compose.yml
echo '      - "traefik.http.routers.qbittorrent.tls=true"'>>qbittorrent/docker-compose.yml
echo 'networks:'>>qbittorrent/docker-compose.yml
echo '  traefik-net:'>>qbittorrent/docker-compose.yml
echo '    external: true'>>qbittorrent/docker-compose.yml

echo  'makind directory for filebrowser'
mkdir -p filebrowser

echo 'version: "3"'>> filebrowser/docker-compose.yml
echo 'services:'>> filebrowser/docker-compose.yml
echo '  filebrowser:'>> filebrowser/docker-compose.yml
echo '    image: filebrowser/filebrowser:latest'>> filebrowser/docker-compose.yml
echo '    user: "${UID}:${GID}"'>> filebrowser/docker-compose.yml
echo '    ports:'>> filebrowser/docker-compose.yml
echo '      - 3000'>> filebrowser/docker-compose.yml
echo '    volumes:'>> filebrowser/docker-compose.yml
echo '      - ../qbittorrent/downloads:/srv'>> filebrowser/docker-compose.yml
echo '      - ./config:/config'>> filebrowser/docker-compose.yml
echo '    environment:'>> filebrowser/docker-compose.yml
echo '      - FB_BASEURL=/filebrowser'>> filebrowser/docker-compose.yml
echo '    restart: always'>> filebrowser/docker-compose.yml
echo '    networks:'>>filebrowser/docker-compose.yml
echo '      - traefik-net'>>filebrowser/docker-compose.yml
echo '    labels:'>>filebrowser/docker-compose.yml
echo '      - "traefik.enable=true"'>>filebrowser/docker-compose.yml
echo '      - "traefik.http.routers.filebrowser.rule=Host(`sub.domain.com`)"'>>filebrowser/docker-compose.yml
echo '      - "traefik.http.services.filebrowser.loadbalancer.server.port=3000"'>>filebrowser/docker-compose.yml
echo '      - "traefik.http.routers.filebrowser.tls.certresolver=lets-encrypt"'>>filebrowser/docker-compose.yml
echo '      - "traefik.http.routers.filebrowser.tls=true"'>>filebrowser/docker-compose.yml
echo 'networks:'>>filebrowser/docker-compose.yml
echo '  traefik-net:'>>filebrowser/docker-compose.yml
echo '    external: true'>>filebrowser/docker-compose.yml
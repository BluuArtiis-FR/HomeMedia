#!/bin/bash

# 🐳 HomeLab Media Server - Générateur Docker Compose Modulaire
# Par BluuArtiis-FR

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Variables
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
SERVICES_SELECTED=()

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║      Générateur Docker Compose       ║"
    echo "║      HomeLab Media Server            ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Menu interactif de sélection des services
select_services() {
    echo -e "${YELLOW}📋 Sélectionnez les services à inclure:${NC}"
    echo

    declare -A services=(
        ["jellyfin"]="🎬 Jellyfin - Serveur média streaming (8096)"
        ["jellyseerr"]="📱 Jellyseerr - Interface de requêtes (5055)"
        ["sonarr"]="📺 Sonarr - Gestion séries TV (8989)"
        ["radarr"]="🎞️ Radarr - Gestion films (7878)"
        ["lidarr"]="🎵 Lidarr - Gestion musique (8686)"
        ["readarr"]="📚 Readarr - Gestion livres (8787)"
        ["qbittorrent"]="⬇️ qBittorrent - Client torrent (8080)"
        ["prowlarr"]="🔍 Prowlarr - Indexeurs centralisés (9696)"
        ["bazarr"]="📝 Bazarr - Sous-titres automatiques (6767)"
        ["flaresolverr"]="🛡️ FlareSolverr - Bypass Cloudflare (8191)"
    )

    declare -A defaults=(
        ["jellyfin"]="ON"
        ["jellyseerr"]="ON"
        ["sonarr"]="ON"
        ["radarr"]="ON"
        ["lidarr"]="OFF"
        ["readarr"]="OFF"
        ["qbittorrent"]="ON"
        ["prowlarr"]="ON"
        ["bazarr"]="ON"
        ["flaresolverr"]="ON"
    )

    # Affichage menu
    i=1
    for service in jellyfin jellyseerr sonarr radarr lidarr readarr qbittorrent prowlarr bazarr flaresolverr; do
        status="${defaults[$service]}"
        echo "[$i] ${services[$service]} [$status]"
        ((i++))
    done

    echo
    echo "💡 Appuyez sur Entrée pour configuration par défaut"
    echo "   Ou tapez les numéros à modifier (ex: 5,6 pour activer Lidarr+Readarr)"
    read -p "Votre choix: " choice

    # Traitement choix
    if [[ -n "$choice" ]]; then
        IFS=',' read -ra modifications <<< "$choice"
        for mod in "${modifications[@]}"; do
            case $mod in
                1) defaults["jellyfin"]=$([[ "${defaults["jellyfin"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                2) defaults["jellyseerr"]=$([[ "${defaults["jellyseerr"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                3) defaults["sonarr"]=$([[ "${defaults["sonarr"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                4) defaults["radarr"]=$([[ "${defaults["radarr"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                5) defaults["lidarr"]=$([[ "${defaults["lidarr"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                6) defaults["readarr"]=$([[ "${defaults["readarr"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                7) defaults["qbittorrent"]=$([[ "${defaults["qbittorrent"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                8) defaults["prowlarr"]=$([[ "${defaults["prowlarr"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                9) defaults["bazarr"]=$([[ "${defaults["bazarr"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
                10) defaults["flaresolverr"]=$([[ "${defaults["flaresolverr"]}" == "ON" ]] && echo "OFF" || echo "ON") ;;
            esac
        done
    fi

    # Construction liste services actifs
    for service in jellyfin jellyseerr sonarr radarr lidarr readarr qbittorrent prowlarr bazarr flaresolverr; do
        if [[ "${defaults[$service]}" == "ON" ]]; then
            SERVICES_SELECTED+=("$service")
        fi
    done

    echo -e "${GREEN}✅ Services sélectionnés: ${SERVICES_SELECTED[*]}${NC}"
}

# Génération du docker-compose.yml
generate_compose() {
    echo -e "${BLUE}🔧 Génération du docker-compose.yml...${NC}"

    cat > "$COMPOSE_FILE" << 'COMPOSE_HEADER'
# Version Docker Compose (optionnelle depuis v2.x)

networks:
  homelab:
    driver: bridge

volumes:
  gluetun_config:

services:
  # 🔒 VPN Container - Obligatoire pour sécurité
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
COMPOSE_HEADER

    # Ports dynamiques selon services VPN
    [[ " ${SERVICES_SELECTED[*]} " =~ " qbittorrent " ]] && echo '      - "8080:8080"   # qBittorrent' >> "$COMPOSE_FILE"
    [[ " ${SERVICES_SELECTED[*]} " =~ " prowlarr " ]] && echo '      - "9696:9696"   # Prowlarr' >> "$COMPOSE_FILE"
    [[ " ${SERVICES_SELECTED[*]} " =~ " flaresolverr " ]] && echo '      - "8191:8191"   # FlareSolverr' >> "$COMPOSE_FILE"

    cat >> "$COMPOSE_FILE" << 'COMPOSE_GLUETUN'
    volumes:
      - gluetun_config:/gluetun
    environment:
      - VPN_SERVICE_PROVIDER=${VPN_SERVICE_PROVIDER:-protonvpn}
      - VPN_TYPE=${VPN_TYPE:-openvpn}
      - OPENVPN_USER=${OPENVPN_USER}
      - OPENVPN_PASSWORD=${OPENVPN_PASSWORD}
      - SERVER_COUNTRIES=${SERVER_COUNTRIES:-France}
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: unless-stopped

COMPOSE_GLUETUN

    # Génération services individuels
    for service in "${SERVICES_SELECTED[@]}"; do
        generate_service_config "$service"
    done

    echo -e "${GREEN}✅ $COMPOSE_FILE généré avec ${#SERVICES_SELECTED[@]} services${NC}"
}

# Génération configuration par service
generate_service_config() {
    local service=$1

    case $service in
        "jellyfin")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 🎬 Jellyfin - Serveur Média
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    ports:
      - "${JELLYFIN_PORT:-8096}:8096"
    volumes:
      - ${CONFIG_PATH:-./config}/jellyfin:/config
      - ${MEDIA_PATH:-./media}:/media:ro
      - /tmp/jellyfin-cache:/cache
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: ${RESTART_POLICY:-unless-stopped}

EOF
            ;;

        "jellyseerr")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 📱 Jellyseerr - Interface Requêtes
  jellyseerr:
    image: fallenbagel/jellyseerr:develop
    container_name: jellyseerr
    ports:
      - "${JELLYSEERR_PORT:-5055}:5055"
    volumes:
      - ${CONFIG_PATH:-./config}/jellyseerr:/app/config
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: ${RESTART_POLICY:-unless-stopped}

EOF
            ;;

        "sonarr")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 📺 Sonarr - Gestion Séries TV et Anime
  sonarr:
    image: linuxserver/sonarr:latest
    container_name: sonarr
    ports:
      - "${SONARR_PORT:-8989}:8989"
    volumes:
      - ${CONFIG_PATH:-./config}/sonarr:/config
      - ${MEDIA_PATH:-./media}/tv:/tv
      - ${MEDIA_PATH:-./media}/anime:/anime
      - ${DOWNLOADS_PATH:-./downloads}:/downloads
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: ${RESTART_POLICY:-unless-stopped}

EOF
            ;;

        "radarr")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 🎞️ Radarr - Gestion Films
  radarr:
    image: linuxserver/radarr:latest
    container_name: radarr
    ports:
      - "${RADARR_PORT:-7878}:7878"
    volumes:
      - ${CONFIG_PATH:-./config}/radarr:/config
      - ${MEDIA_PATH:-./media}/movies:/movies
      - ${DOWNLOADS_PATH:-./downloads}:/downloads
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: ${RESTART_POLICY:-unless-stopped}

EOF
            ;;

        "qbittorrent")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # ⬇️ qBittorrent - Client Torrent (via VPN)
  qbittorrent:
    image: linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "service:gluetun"
    volumes:
      - ${CONFIG_PATH:-./config}/qbittorrent:/config
      - ${DOWNLOADS_PATH:-./downloads}:/downloads
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-Europe/Paris}
      - WEBUI_PORT=8080
    restart: ${RESTART_POLICY:-unless-stopped}
    depends_on:
      - gluetun

EOF
            ;;

        "prowlarr")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 🔍 Prowlarr - Indexeurs (via VPN)
  prowlarr:
    image: linuxserver/prowlarr:latest
    container_name: prowlarr
    network_mode: "service:gluetun"
    volumes:
      - ${CONFIG_PATH:-./config}/prowlarr:/config
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-Europe/Paris}
    restart: ${RESTART_POLICY:-unless-stopped}
    depends_on:
      - gluetun

EOF
            ;;

        "bazarr")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 📝 Bazarr - Sous-titres Automatiques
  bazarr:
    image: linuxserver/bazarr:latest
    container_name: bazarr
    ports:
      - "${BAZARR_PORT:-6767}:6767"
    volumes:
      - ${CONFIG_PATH:-./config}/bazarr:/config
      - ${MEDIA_PATH:-./media}/movies:/movies
      - ${MEDIA_PATH:-./media}/tv:/tv
      - ${MEDIA_PATH:-./media}/anime:/anime
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: ${RESTART_POLICY:-unless-stopped}

EOF
            ;;

        "flaresolverr")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 🛡️ FlareSolverr - Bypass Cloudflare (via VPN)
  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    network_mode: "service:gluetun"
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ:-Europe/Paris}
    restart: ${RESTART_POLICY:-unless-stopped}
    depends_on:
      - gluetun

EOF
            ;;

        "lidarr")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 🎵 Lidarr - Gestion Musique
  lidarr:
    image: linuxserver/lidarr:latest
    container_name: lidarr
    ports:
      - "${LIDARR_PORT:-8686}:8686"
    volumes:
      - ${CONFIG_PATH:-./config}/lidarr:/config
      - ${MEDIA_PATH:-./media}/music:/music
      - ${DOWNLOADS_PATH:-./downloads}:/downloads
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: ${RESTART_POLICY:-unless-stopped}

EOF
            ;;

        "readarr")
            cat >> "$COMPOSE_FILE" << 'EOF'
  # 📚 Readarr - Gestion Livres
  readarr:
    image: linuxserver/readarr:develop
    container_name: readarr
    ports:
      - "${READARR_PORT:-8787}:8787"
    volumes:
      - ${CONFIG_PATH:-./config}/readarr:/config
      - ${MEDIA_PATH:-./media}/books:/books
      - ${DOWNLOADS_PATH:-./downloads}:/downloads
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: ${RESTART_POLICY:-unless-stopped}

EOF
            ;;
    esac
}

# Vérification fichier .env
check_env_file() {
    if [[ ! -f "$ENV_FILE" ]]; then
        echo -e "${RED}❌ Fichier .env manquant !${NC}"
        echo "Copiez .env.example vers .env et configurez vos credentials VPN"
        echo "cp .env.example .env"
        exit 1
    fi
    echo -e "${GREEN}✅ Fichier .env trouvé${NC}"
}

# Menu principal
main_menu() {
    while true; do
        echo
        echo -e "${BLUE}🎛️ Que voulez-vous faire ?${NC}"
        echo "1) 🔧 Générer docker-compose.yml personnalisé"
        echo "2) 📋 Voir services disponibles"
        echo "3) 🚀 Démarrer les services"
        echo "4) 🛑 Arrêter les services"
        echo "5) 📊 Status des services"
        echo "6) 🗑️ Nettoyer (reset complet)"
        echo "0) ❌ Quitter"
        echo
        read -p "Votre choix [1-6, 0]: " choice

        case $choice in
            1) generate_full_compose ;;
            2) show_available_services ;;
            3) start_services ;;
            4) stop_services ;;
            5) show_status ;;
            6) cleanup_all ;;
            0) echo "👋 Au revoir !"; exit 0 ;;
            *) echo -e "${RED}❌ Choix invalide${NC}" ;;
        esac
    done
}

# Génération complète
generate_full_compose() {
    check_env_file
    select_services

    echo -e "${BLUE}🔧 Génération du docker-compose.yml...${NC}"

    # Header
    cat > "$COMPOSE_FILE" << 'HEADER'
# Version Docker Compose (optionnelle depuis v2.x)

networks:
  homelab:
    driver: bridge

volumes:
  gluetun_config:

services:
HEADER

    # Gluetun (VPN) - Toujours inclus
    cat >> "$COMPOSE_FILE" << 'GLUETUN'
  # 🔒 VPN Container - Sécurise le trafic torrent
  gluetun:
    image: qmcgaw/gluetun:latest
    container_name: gluetun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
GLUETUN

    # Ports dynamiques
    [[ " ${SERVICES_SELECTED[*]} " =~ " qbittorrent " ]] && echo '      - "${QBITTORRENT_PORT:-8080}:8080"' >> "$COMPOSE_FILE"
    [[ " ${SERVICES_SELECTED[*]} " =~ " prowlarr " ]] && echo '      - "${PROWLARR_PORT:-9696}:9696"' >> "$COMPOSE_FILE"
    [[ " ${SERVICES_SELECTED[*]} " =~ " flaresolverr " ]] && echo '      - "${FLARESOLVERR_PORT:-8191}:8191"' >> "$COMPOSE_FILE"

    cat >> "$COMPOSE_FILE" << 'GLUETUN_END'
    volumes:
      - gluetun_config:/gluetun
    environment:
      - VPN_SERVICE_PROVIDER=${VPN_SERVICE_PROVIDER:-protonvpn}
      - VPN_TYPE=${VPN_TYPE:-openvpn}
      - OPENVPN_USER=${OPENVPN_USER}
      - OPENVPN_PASSWORD=${OPENVPN_PASSWORD}
      - SERVER_COUNTRIES=${SERVER_COUNTRIES:-France}
      - TZ=${TZ:-Europe/Paris}
    networks:
      - homelab
    restart: ${RESTART_POLICY:-unless-stopped}

GLUETUN_END

    # Génération services sélectionnés
    for service in "${SERVICES_SELECTED[@]}"; do
        generate_service_config "$service"
    done

    echo -e "${GREEN}✅ docker-compose.yml généré avec ${#SERVICES_SELECTED[@]} services !${NC}"
    echo "📁 Fichier: $COMPOSE_FILE"
}

# Autres fonctions utilitaires
show_available_services() {
    echo -e "${BLUE}📋 Services Disponibles:${NC}"
    echo "🎬 jellyfin     - Serveur média streaming (8096)"
    echo "📱 jellyseerr   - Interface de requêtes (5055)"
    echo "📺 sonarr       - Gestion séries TV (8989)"
    echo "🎞️ radarr       - Gestion films (7878)"
    echo "🎵 lidarr       - Gestion musique (8686)"
    echo "📚 readarr      - Gestion livres (8787)"
    echo "⬇️ qbittorrent  - Client torrent (8080)"
    echo "🔍 prowlarr     - Indexeurs (9696)"
    echo "📝 bazarr       - Sous-titres (6767)"
    echo "🛡️ flaresolverr - Bypass Cloudflare (8191)"
}

start_services() {
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        echo -e "${RED}❌ docker-compose.yml manquant ! Générez-le d'abord.${NC}"
        return
    fi
    echo -e "${BLUE}🚀 Démarrage des services...${NC}"
    docker compose up -d
    echo -e "${GREEN}✅ Services démarrés !${NC}"
}

stop_services() {
    echo -e "${YELLOW}🛑 Arrêt des services...${NC}"
    docker compose down
    echo -e "${GREEN}✅ Services arrêtés !${NC}"
}

show_status() {
    echo -e "${BLUE}📊 Status des Services:${NC}"
    docker compose ps
}

cleanup_all() {
    echo -e "${RED}⚠️ ATTENTION: Cela va supprimer TOUS les containers et volumes !${NC}"
    read -p "Êtes-vous sûr ? (tapez 'SUPPRIMER' pour confirmer): " confirm
    if [[ "$confirm" == "SUPPRIMER" ]]; then
        docker compose down -v
        docker system prune -a -f
        echo -e "${GREEN}✅ Nettoyage terminé !${NC}"
    else
        echo "❌ Annulé"
    fi
}

# Point d'entrée principal
main() {
    print_header

    # Vérification Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker non installé ! Lancez d'abord install.sh${NC}"
        exit 1
    fi

    main_menu
}

# Exécution
main "$@"

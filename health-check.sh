#!/bin/bash

# 🏥 HomeLab Media Server - Health Check Script
# Vérifie l'état de santé de tous les services

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==========================================
# FONCTIONS UTILITAIRES
# ==========================================

print_header() {
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════╗
║     🏥 HomeLab Media Server - Health Check 🏥       ║
╚══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

success() {
    echo -e "${GREEN}✅ $*${NC}"
}

error() {
    echo -e "${RED}❌ $*${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

info() {
    echo -e "${CYAN}ℹ️  $*${NC}"
}

# ==========================================
# VÉRIFICATIONS SYSTÈME
# ==========================================

check_docker() {
    echo -e "\n${PURPLE}▶ Vérification Docker${NC}"

    if ! command -v docker &> /dev/null; then
        error "Docker n'est pas installé"
        return 1
    fi

    docker_version=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    success "Docker installé: v${docker_version}"

    if ! docker compose version &> /dev/null; then
        error "Docker Compose non disponible"
        return 1
    fi

    compose_version=$(docker compose version --short)
    success "Docker Compose: v${compose_version}"
}

check_system_resources() {
    echo -e "\n${PURPLE}▶ Ressources Système${NC}"

    # CPU
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_cores=$(nproc)
    echo -e "  CPU: ${cpu_cores} cœurs - ${cpu_usage}% utilisé"

    # RAM
    total_ram=$(free -h | awk 'NR==2{print $2}')
    used_ram=$(free -h | awk 'NR==2{print $3}')
    ram_percent=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')

    if [[ $ram_percent -gt 90 ]]; then
        warning "RAM: ${used_ram}/${total_ram} (${ram_percent}%) - Critique!"
    elif [[ $ram_percent -gt 75 ]]; then
        warning "RAM: ${used_ram}/${total_ram} (${ram_percent}%) - Élevé"
    else
        success "RAM: ${used_ram}/${total_ram} (${ram_percent}%)"
    fi

    # Disque
    disk_usage=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)
    disk_available=$(df -h / | awk 'NR==2{print $4}')

    if [[ $disk_usage -gt 90 ]]; then
        warning "Disque: ${disk_usage}% utilisé - ${disk_available} disponible - Critique!"
    elif [[ $disk_usage -gt 75 ]]; then
        warning "Disque: ${disk_usage}% utilisé - ${disk_available} disponible"
    else
        success "Disque: ${disk_usage}% utilisé - ${disk_available} disponible"
    fi
}

# ==========================================
# VÉRIFICATIONS SERVICES DOCKER
# ==========================================

check_docker_services() {
    echo -e "\n${PURPLE}▶ État des Services Docker${NC}"

    if [[ ! -f docker-compose.yml ]]; then
        error "Fichier docker-compose.yml introuvable"
        return 1
    fi

    # Liste des services
    services=(
        "gluetun:VPN Container"
        "jellyfin:Serveur Média"
        "jellyseerr:Interface Requêtes"
        "sonarr:Gestion Séries"
        "radarr:Gestion Films"
        "qbittorrent:Client Torrent"
        "prowlarr:Indexeurs"
        "bazarr:Sous-titres"
        "flaresolverr:Bypass Cloudflare"
    )

    healthy=0
    unhealthy=0

    for service_info in "${services[@]}"; do
        IFS=':' read -r service name <<< "$service_info"

        # Vérifier si le container existe
        if docker ps -a --format '{{.Names}}' | grep -q "^${service}$"; then
            # Vérifier si le container est en cours d'exécution
            status=$(docker inspect -f '{{.State.Status}}' "$service" 2>/dev/null || echo "unknown")

            case $status in
                running)
                    # Vérifier l'uptime
                    started=$(docker inspect -f '{{.State.StartedAt}}' "$service")
                    uptime=$(date -d "$started" +%s)
                    now=$(date +%s)
                    runtime=$((now - uptime))

                    if [[ $runtime -gt 60 ]]; then
                        runtime_human="$(($runtime / 60))m"
                    else
                        runtime_human="${runtime}s"
                    fi

                    success "${name} (${service}) - Running (uptime: ${runtime_human})"
                    ((healthy++))
                    ;;
                restarting)
                    warning "${name} (${service}) - Redémarrage en cours"
                    ((unhealthy++))
                    ;;
                exited)
                    error "${name} (${service}) - Arrêté"
                    ((unhealthy++))
                    ;;
                *)
                    warning "${name} (${service}) - État inconnu: $status"
                    ((unhealthy++))
                    ;;
            esac
        else
            info "${name} (${service}) - Non déployé"
        fi
    done

    echo ""
    echo -e "${CYAN}📊 Résumé: ${GREEN}${healthy} OK${NC} | ${RED}${unhealthy} KO${NC}"
}

# ==========================================
# VÉRIFICATIONS RÉSEAU
# ==========================================

check_network_connectivity() {
    echo -e "\n${PURPLE}▶ Connectivité Réseau${NC}"

    # Test VPN (via gluetun)
    if docker ps --format '{{.Names}}' | grep -q "^gluetun$"; then
        if docker inspect -f '{{.State.Status}}' gluetun | grep -q "running"; then
            # Vérifier l'IP externe via le VPN
            vpn_ip=$(docker exec gluetun wget -qO- https://api.ipify.org 2>/dev/null || echo "N/A")

            if [[ "$vpn_ip" != "N/A" ]]; then
                success "VPN actif - IP externe: ${vpn_ip}"
            else
                warning "VPN démarré mais IP non récupérable"
            fi
        else
            error "VPN non actif"
        fi
    else
        warning "Container VPN non trouvé"
    fi

    # Test connectivité Internet
    if ping -c 1 8.8.8.8 &> /dev/null; then
        success "Connectivité Internet OK"
    else
        error "Pas de connectivité Internet"
    fi
}

# ==========================================
# VÉRIFICATIONS PORTS
# ==========================================

check_ports() {
    echo -e "\n${PURPLE}▶ Ports Ouverts${NC}"

    declare -A ports=(
        ["8096"]="Jellyfin"
        ["5055"]="Jellyseerr"
        ["8989"]="Sonarr"
        ["7878"]="Radarr"
        ["8080"]="qBittorrent"
        ["9696"]="Prowlarr"
        ["6767"]="Bazarr"
    )

    for port in "${!ports[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":${port} " || ss -tuln 2>/dev/null | grep -q ":${port} "; then
            success "Port ${port} (${ports[$port]}) - Ouvert"
        else
            info "Port ${port} (${ports[$port]}) - Fermé/Non utilisé"
        fi
    done
}

# ==========================================
# VÉRIFICATIONS VOLUMES
# ==========================================

check_volumes() {
    echo -e "\n${PURPLE}▶ Volumes Docker${NC}"

    volumes=$(docker volume ls --format '{{.Name}}' | grep -E 'homelab|gluetun' || true)

    if [[ -n "$volumes" ]]; then
        while IFS= read -r volume; do
            size=$(docker system df -v | grep "$volume" | awk '{print $3}' || echo "N/A")
            success "Volume: ${volume} (${size})"
        done <<< "$volumes"
    else
        warning "Aucun volume trouvé"
    fi
}

# ==========================================
# LOGS RÉCENTS
# ==========================================

show_recent_errors() {
    echo -e "\n${PURPLE}▶ Erreurs Récentes (dernières 24h)${NC}"

    error_count=0

    for container in $(docker ps --format '{{.Names}}'); do
        errors=$(docker logs --since 24h "$container" 2>&1 | grep -iE 'error|fatal|critical' | wc -l)

        if [[ $errors -gt 0 ]]; then
            warning "${container}: ${errors} erreur(s) détectée(s)"
            ((error_count += errors))
        fi
    done

    if [[ $error_count -eq 0 ]]; then
        success "Aucune erreur détectée"
    else
        warning "Total: ${error_count} erreur(s) dans les logs"
        info "Consultez les logs: docker compose logs -f [service]"
    fi
}

# ==========================================
# RECOMMANDATIONS
# ==========================================

show_recommendations() {
    echo -e "\n${PURPLE}▶ Recommandations${NC}"

    # Vérifier mises à jour images
    outdated=$(docker images --format "{{.Repository}}:{{.Tag}}" | xargs -I {} docker pull {} --quiet 2>&1 | grep -c "up to date" || echo "0")

    info "Mettre à jour les images: docker compose pull && docker compose up -d"
    info "Nettoyer les ressources: docker system prune -a"
    info "Sauvegarder configs: tar -czf backup-$(date +%F).tar.gz /opt/homelab/config"
}

# ==========================================
# RAPPORT FINAL
# ==========================================

generate_summary() {
    echo -e "\n${BLUE}══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🏥 Vérification de santé terminée${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}\n"

    echo -e "${CYAN}📅 Date: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}💻 Hôte: $(hostname)${NC}\n"
}

# ==========================================
# MAIN
# ==========================================

main() {
    print_header

    check_docker
    check_system_resources
    check_docker_services
    check_network_connectivity
    check_ports
    check_volumes
    show_recent_errors
    show_recommendations

    generate_summary
}

# Exécution
main "$@"

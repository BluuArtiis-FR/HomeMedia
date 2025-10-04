#!/bin/bash

# 🚀 HomeLab Media Server - Installation Automatique
# Par BluuArtiis-FR
# Licence MIT

set -euo pipefail

# ==========================================
# CONFIGURATION
# ==========================================
VERSION="1.0.0"
LOG_FILE="/var/log/homelab-install.log"
INSTALL_DIR="/opt/homelab"
COMPOSE_VERSION="v2.24.5"

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

print_banner() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║        🏠 HomeLab Media Server - Installation 🏠        ║
║                                                          ║
║         Serveur Média Automatisé Sécurisé                ║
║                   Version 1.0.0                          ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log() {
    echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $*${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ ERREUR: $*${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  ATTENTION: $*${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${CYAN}ℹ️  $*${NC}" | tee -a "$LOG_FILE"
}

step() {
    echo -e "${PURPLE}▶ $*${NC}" | tee -a "$LOG_FILE"
}

# Vérification root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Ce script doit être exécuté en tant que root (sudo)"
        exit 1
    fi
}

# Vérification OS
check_os() {
    step "Vérification du système d'exploitation..."

    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        info "OS détecté: $PRETTY_NAME"

        case $OS in
            ubuntu|debian|centos|rhel|fedora)
                success "OS supporté"
                ;;
            *)
                warning "OS non officiellement supporté: $OS"
                read -p "Continuer quand même ? (y/N): " -n 1 -r
                echo
                [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
                ;;
        esac
    else
        error "Impossible de détecter l'OS"
        exit 1
    fi
}

# Vérification ressources système
check_system_resources() {
    step "Vérification des ressources système..."

    # RAM
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $total_ram -lt 4 ]]; then
        warning "RAM insuffisante: ${total_ram}GB (4GB minimum recommandé)"
    else
        success "RAM: ${total_ram}GB"
    fi

    # CPU
    cpu_cores=$(nproc)
    if [[ $cpu_cores -lt 2 ]]; then
        warning "CPU insuffisant: ${cpu_cores} cœurs (2 minimum recommandé)"
    else
        success "CPU: ${cpu_cores} cœurs"
    fi

    # Stockage
    available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $available_space -lt 50 ]]; then
        warning "Espace disque faible: ${available_space}GB (50GB minimum recommandé)"
    else
        success "Espace disque: ${available_space}GB disponible"
    fi
}

# ==========================================
# INSTALLATION DOCKER
# ==========================================

install_docker() {
    step "Installation de Docker..."

    if command -v docker &> /dev/null; then
        docker_version=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
        info "Docker déjà installé: v${docker_version}"
        return 0
    fi

    info "Téléchargement et installation de Docker..."

    case $OS in
        ubuntu|debian)
            # Mise à jour
            apt-get update -qq
            apt-get install -y ca-certificates curl gnupg lsb-release

            # Ajout du repository Docker
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$OS/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
              $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Installation
            apt-get update -qq
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;

        centos|rhel|fedora)
            yum install -y yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            systemctl start docker
            ;;

        *)
            error "Installation Docker non supportée pour cet OS"
            exit 1
            ;;
    esac

    # Démarrage Docker
    systemctl enable docker
    systemctl start docker

    # Ajout utilisateur au groupe docker
    if [[ -n "${SUDO_USER:-}" ]]; then
        usermod -aG docker "$SUDO_USER"
        success "Utilisateur $SUDO_USER ajouté au groupe docker"
    fi

    success "Docker installé avec succès"
}

# Vérification Docker Compose
check_docker_compose() {
    step "Vérification de Docker Compose..."

    if docker compose version &> /dev/null; then
        compose_version=$(docker compose version --short)
        success "Docker Compose installé: v${compose_version}"
    else
        error "Docker Compose non disponible"
        exit 1
    fi
}

# ==========================================
# CONFIGURATION SYSTÈME
# ==========================================

configure_firewall() {
    step "Configuration du pare-feu UFW..."

    if ! command -v ufw &> /dev/null; then
        info "Installation de UFW..."
        case $OS in
            ubuntu|debian)
                apt-get install -y ufw
                ;;
            centos|rhel|fedora)
                yum install -y ufw
                ;;
        esac
    fi

    # Configuration UFW
    info "Configuration des règles de pare-feu..."

    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing

    # Ports essentiels
    ufw allow 22/tcp comment 'SSH'
    ufw allow 8096/tcp comment 'Jellyfin'
    ufw allow 5055/tcp comment 'Jellyseerr'
    ufw allow 8989/tcp comment 'Sonarr'
    ufw allow 7878/tcp comment 'Radarr'
    ufw allow 8080/tcp comment 'qBittorrent'
    ufw allow 9696/tcp comment 'Prowlarr'
    ufw allow 6767/tcp comment 'Bazarr'
    ufw allow 8686/tcp comment 'Lidarr'
    ufw allow 8787/tcp comment 'Readarr'

    ufw reload

    success "Pare-feu configuré"
}

install_fail2ban() {
    step "Installation de Fail2Ban..."

    if command -v fail2ban-client &> /dev/null; then
        info "Fail2Ban déjà installé"
        return 0
    fi

    case $OS in
        ubuntu|debian)
            apt-get install -y fail2ban
            ;;
        centos|rhel|fedora)
            yum install -y epel-release
            yum install -y fail2ban fail2ban-systemd
            ;;
    esac

    # Configuration basique
    cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 22
logpath = /var/log/auth.log
EOF

    systemctl enable fail2ban
    systemctl start fail2ban

    success "Fail2Ban installé et configuré"
}

# ==========================================
# CRÉATION STRUCTURE
# ==========================================

create_directory_structure() {
    step "Création de la structure de dossiers..."

    # Création des répertoires principaux
    mkdir -p "$INSTALL_DIR"/{config,data,downloads,media}
    mkdir -p "$INSTALL_DIR"/media/{movies,tv,music,books}
    mkdir -p "$INSTALL_DIR"/config/{jellyfin,sonarr,radarr,lidarr,readarr,qbittorrent,prowlarr,bazarr,jellyseerr}

    # Permissions
    if [[ -n "${SUDO_USER:-}" ]]; then
        chown -R "$SUDO_USER":"$SUDO_USER" "$INSTALL_DIR"
        success "Permissions configurées pour l'utilisateur $SUDO_USER"
    fi

    chmod -R 755 "$INSTALL_DIR"

    success "Structure de dossiers créée: $INSTALL_DIR"
}

# ==========================================
# CONFIGURATION .ENV
# ==========================================

configure_env_file() {
    step "Configuration du fichier .env..."

    if [[ -f .env ]]; then
        warning "Fichier .env existant détecté"
        read -p "Voulez-vous le reconfigurer ? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 0
    fi

    # Copie du template
    if [[ -f .env.example ]]; then
        cp .env.example .env
        info "Template .env créé"
    else
        error "Fichier .env.example introuvable"
        return 1
    fi

    # Configuration interactive
    echo -e "\n${YELLOW}📝 Configuration VPN ProtonVPN${NC}"
    read -p "Nom d'utilisateur ProtonVPN: " vpn_user
    read -sp "Mot de passe ProtonVPN: " vpn_pass
    echo

    # Modification du fichier .env
    sed -i "s/OPENVPN_USER=.*/OPENVPN_USER=$vpn_user/" .env
    sed -i "s/OPENVPN_PASSWORD=.*/OPENVPN_PASSWORD=$vpn_pass/" .env

    # PUID/PGID
    if [[ -n "${SUDO_USER:-}" ]]; then
        user_uid=$(id -u "$SUDO_USER")
        user_gid=$(id -g "$SUDO_USER")
        sed -i "s/PUID=.*/PUID=$user_uid/" .env
        sed -i "s/PGID=.*/PGID=$user_gid/" .env
    fi

    # Chemins
    sed -i "s|CONFIG_PATH=.*|CONFIG_PATH=$INSTALL_DIR/config|" .env
    sed -i "s|DATA_PATH=.*|DATA_PATH=$INSTALL_DIR/data|" .env
    sed -i "s|DOWNLOADS_PATH=.*|DOWNLOADS_PATH=$INSTALL_DIR/downloads|" .env
    sed -i "s|MEDIA_PATH=.*|MEDIA_PATH=$INSTALL_DIR/media|" .env

    chmod 600 .env
    success "Fichier .env configuré"
}

# ==========================================
# DÉPLOIEMENT DOCKER
# ==========================================

generate_docker_compose() {
    step "Génération du docker-compose.yml..."

    if [[ -x ./generate-compose.sh ]]; then
        info "Utilisation du générateur modulaire..."
        # Génération automatique avec config par défaut
        ./generate-compose.sh << 'INPUT'


INPUT
        success "docker-compose.yml généré"
    else
        warning "Script generate-compose.sh non trouvé ou non exécutable"
        return 1
    fi
}

deploy_containers() {
    step "Déploiement des containers Docker..."

    if [[ ! -f docker-compose.yml ]]; then
        error "Fichier docker-compose.yml introuvable"
        return 1
    fi

    info "Téléchargement des images Docker..."
    docker compose pull

    info "Démarrage des services..."
    docker compose up -d

    success "Containers déployés"
}

# ==========================================
# VÉRIFICATIONS POST-INSTALLATION
# ==========================================

check_services_health() {
    step "Vérification de la santé des services..."

    sleep 10  # Attente démarrage

    info "Status des containers:"
    docker compose ps

    echo ""
    info "Services accessibles sur:"
    echo -e "${GREEN}  🎬 Jellyfin:    http://$(hostname -I | awk '{print $1}'):8096${NC}"
    echo -e "${GREEN}  📱 Jellyseerr:  http://$(hostname -I | awk '{print $1}'):5055${NC}"
    echo -e "${GREEN}  📺 Sonarr:      http://$(hostname -I | awk '{print $1}'):8989${NC}"
    echo -e "${GREEN}  🎞️  Radarr:      http://$(hostname -I | awk '{print $1}'):7878${NC}"
    echo -e "${GREEN}  ⬇️  qBittorrent: http://$(hostname -I | awk '{print $1}'):8080${NC}"
    echo -e "${GREEN}  🔍 Prowlarr:    http://$(hostname -I | awk '{print $1}'):9696${NC}"
    echo ""
}

# ==========================================
# MENU PRINCIPAL
# ==========================================

show_summary() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Installation terminée avec succès !${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}\n"

    echo -e "${YELLOW}📋 Prochaines étapes:${NC}"
    echo -e "  1. Configurez Jellyfin: http://$(hostname -I | awk '{print $1}'):8096"
    echo -e "  2. Configurez Prowlarr et ajoutez des indexeurs"
    echo -e "  3. Configurez Sonarr/Radarr et liez-les à Prowlarr"
    echo -e "  4. Configurez qBittorrent (user: admin, pass: adminadmin)"
    echo -e "  5. Configurez Jellyseerr et liez-le à Jellyfin\n"

    echo -e "${CYAN}📖 Documentation complète:${NC}"
    echo -e "  - Guide configuration: docs/configuration.md"
    echo -e "  - Dépannage: docs/troubleshooting.md"
    echo -e "  - FAQ: docs/faq.md\n"

    echo -e "${PURPLE}🔧 Commandes utiles:${NC}"
    echo -e "  - Voir les logs:       docker compose logs -f"
    echo -e "  - Arrêter services:    docker compose down"
    echo -e "  - Redémarrer:          docker compose restart"
    echo -e "  - Santé système:       ./health-check.sh\n"

    info "Logs d'installation: $LOG_FILE"
}

# ==========================================
# INSTALLATION PRINCIPALE
# ==========================================

main() {
    print_banner

    # Initialisation log
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"

    log "=== Début de l'installation HomeLab Media Server v${VERSION} ==="

    # Vérifications préliminaires
    check_root
    check_os
    check_system_resources

    echo ""
    warning "Cette installation va modifier votre système:"
    echo "  - Installation de Docker et Docker Compose"
    echo "  - Configuration du pare-feu UFW"
    echo "  - Installation de Fail2Ban"
    echo "  - Création de dossiers dans $INSTALL_DIR"
    echo ""
    read -p "Continuer ? (y/N): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

    # Installation
    echo ""
    install_docker
    check_docker_compose
    configure_firewall
    install_fail2ban
    create_directory_structure
    configure_env_file
    generate_docker_compose
    deploy_containers
    check_services_health

    # Résumé
    show_summary

    log "=== Installation terminée avec succès ==="

    success "🎉 Bienvenue dans votre HomeLab Media Server !"
}

# Point d'entrée
main "$@"

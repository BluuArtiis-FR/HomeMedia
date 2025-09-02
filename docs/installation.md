# 📦 Guide d'Installation Détaillé

## Prérequis Système

### Configuration Minimale
- **OS** : Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **RAM** : 4 GB minimum (8 GB recommandé)
- **CPU** : 2 cœurs minimum (4 cœurs recommandé)
- **Stockage** : 50 GB minimum pour le système + espace pour médias
- **Réseau** : Connexion internet stable

### Configuration Recommandée
- **RAM** : 16 GB
- **CPU** : 6+ cœurs
- **Stockage** : SSD pour système + HDD pour médias
- **Réseau** : 100 Mbps+ pour streaming multiple

## Installation Automatique

### 1. Téléchargement
```bash
git clone https://github.com/BluuArtiis-FR/homelab-media-server.git
cd homelab-media-server
```

### 2. Configuration
```bash
# Copier le template de configuration
cp .env.example .env

# Modifier avec vos credentials VPN
nano .env
```

### 3. Installation
```bash
# Rendre le script exécutable
chmod +x install.sh

# Lancer l'installation interactive
sudo ./install.sh
```

Le script va :
- ✅ Vérifier les prérequis
- ✅ Installer Docker & Docker Compose
- ✅ Configurer UFW (firewall)
- ✅ Installer Fail2Ban
- ✅ Créer les dossiers nécessaires
- ✅ Configurer les permissions
- ✅ Démarrer tous les services

## Installation Manuelle

### 1. Docker & Docker Compose
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Structure des Dossiers
```bash
sudo mkdir -p /opt/homelab/{config,data,downloads,media}
sudo mkdir -p /opt/homelab/media/{movies,tv,music,books}
sudo chown -R $USER:$USER /opt/homelab
```

### 3. Sécurité
```bash
# UFW
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Ports nécessaires
sudo ufw allow 8096  # Jellyfin
sudo ufw allow 5055  # Jellyseerr
sudo ufw allow 22    # SSH

# Fail2Ban
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
```

### 4. Déploiement
```bash
docker compose up -d
```

## Configuration Post-Installation

### 1. Accès aux Services
- **Jellyfin** : http://votre-ip:8096
- **Jellyseerr** : http://votre-ip:5055
- **Sonarr** : http://votre-ip:8989
- **Radarr** : http://votre-ip:7878

### 2. Configuration VPN
1. Modifier `.env` avec vos credentials ProtonVPN
2. Redémarrer : `docker compose restart gluetun`

### 3. Première Configuration
Suivez le [guide de configuration](configuration.md) pour configurer chaque service.

## Dépannage Installation

### Problèmes Courants

#### Docker non accessible
```bash
sudo usermod -aG docker $USER
newgrp docker
```

#### Ports déjà utilisés
```bash
sudo netstat -tulpn | grep :8096
sudo systemctl stop service-conflictuel
```

#### Permissions insuffisantes
```bash
sudo chown -R $USER:$USER /opt/homelab
sudo chmod -R 755 /opt/homelab
```

### Logs d'Installation
```bash
# Voir les logs du script
tail -f /var/log/homelab-install.log

# Logs Docker
docker compose logs -f
```

## Désinstallation

### Arrêt des Services
```bash
docker compose down -v
```

### Suppression Complète
```bash
sudo rm -rf /opt/homelab
docker system prune -a --volumes
```

⚠️ **Attention** : Cela supprimera toutes vos données !

# 🏠 HomeLab Media Server

[![GitHub release](https://img.shields.io/github/release/BluuArtiis-FR/homelab-media-server.svg)](https://github.com/BluuArtiis-FR/homelab-media-server/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Compatible-blue.svg)](https://www.docker.com/)

**Serveur média automatisé complet avec VPN, téléchargement automatique et streaming 1080p optimisé sans GPU.**

## 📋 Table des Matières
- [Aperçu](#aperçu)
- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture)
- [Installation Rapide](#installation-rapide)
- [Configuration](#configuration)
- [Services Inclus](#services-inclus)
- [Sécurité](#sécurité)
- [Documentation](#documentation)
- [Contribution](#contribution)
- [Licence](#licence)

## 🎯 Aperçu

Ce projet fournit une solution complète et automatisée pour déployer un serveur média domestique avec :
- **Streaming 1080p optimisé** (sans GPU requis)
- **VPN intégré** avec ProtonVPN/Gluetun
- **Téléchargement automatique** via qBittorrent + Prowlarr
- **Gestion de contenu** Sonarr, Radarr, Lidarr, Readarr
- **Sécurité renforcée** UFW, Fail2Ban, SSL automatique

## ⚡ Installation Rapide

```bash
# Cloner le repository
git clone https://github.com/BluuArtiis-FR/homelab-media-server.git
cd homelab-media-server

# Copier le fichier de configuration
cp .env.example .env
# Modifier .env avec vos credentials VPN

# Rendre les scripts exécutables
chmod +x install.sh generate-compose.sh

# Installation automatique
sudo ./install.sh

# OU génération modulaire
./generate-compose.sh
```

## ✨ Fonctionnalités

### 🎬 **Services Média**
- **Jellyfin** (8096) - Serveur de streaming média
- **Jellyseerr** (5055) - Interface de requêtes compatible Jellyfin

### 📚 **Gestion de Contenu**
- **Sonarr** (8989) - Gestion automatique des séries TV
- **Radarr** (7878) - Gestion automatique des films
- **Lidarr** (8686) - Gestion de la musique (support Spotify)
- **Readarr** (8787) - Gestion des livres et audiobooks

### ⬇️ **Téléchargement & Indexation**
- **qBittorrent** (8080) - Client torrent avec interface web
- **Prowlarr** (9696) - Gestionnaire d'indexeurs centralisé
- **FlareSolverr** (8191) - Contournement Cloudflare

### 🔒 **Sécurité & VPN**
- **Gluetun** - Container VPN (ProtonVPN/autres)
- **UFW** - Firewall configuré automatiquement
- **Fail2Ban** - Protection anti-bruteforce
- **SSL** - Certificats Let's Encrypt automatiques

### 🌟 **Améliorations**
- **Bazarr** (6767) - Sous-titres multi-langues automatiques

## 🏗️ Architecture

```
Internet → ProtonVPN → Serveur Principal ← → Reverse Proxy SSL
    ↓
    [Services Média]  [Gestion Contenu]  [Téléchargement]
```

Consultez le [schéma détaillé](docs/architecture.md) pour plus d'informations.

## ⚙️ Configuration

### 1. **Fichier .env**
```bash
# Copier le template
cp .env.example .env

# Modifier avec vos credentials
nano .env
```

### 2. **Credentials VPN Requis**
- Nom d'utilisateur ProtonVPN
- Mot de passe ProtonVPN
- Serveur préféré (optionnel)

### 3. **Génération Modulaire**
```bash
# Script interactif pour choisir les services
./generate-compose.sh
```

Voir le [guide de configuration détaillé](docs/configuration.md).

## 🚀 Services Inclus

| Service | Port | Description | VPN |
|----|----|----|:----:|
| Jellyfin | 8096 | Serveur média streaming | ❌ |
| Jellyseerr | 5055 | Interface requêtes média | ❌ |
| Sonarr | 8989 | Gestion séries TV | ❌ |
| Radarr | 7878 | Gestion films | ❌ |
| Lidarr | 8686 | Gestion musique | ❌ |
| Readarr | 8787 | Gestion livres | ❌ |
| qBittorrent | 8080 | Client torrent | ✅ |
| Prowlarr | 9696 | Indexeurs centralisés | ✅ |
| FlareSolverr | 8191 | Bypass Cloudflare | ✅ |
| Bazarr | 6767 | Sous-titres automatiques | ❌ |

## 🔒 Sécurité

### Protection Réseau
- **VPN obligatoire** pour téléchargements
- **Firewall UFW** avec règles strictes
- **Fail2Ban** anti-bruteforce SSH
- **Isolation containers** Docker

### Bonnes Pratiques
- Credentials VPN sécurisés
- Ports non-standard disponibles
- Logs de sécurité centralisés
- Mises à jour automatiques

Voir le [guide sécurité](docs/troubleshooting.md#sécurité).

## 📖 Documentation

- [Guide d'installation détaillé](docs/installation.md)
- [Configuration des services](docs/configuration.md)
- [Guide de dépannage](docs/troubleshooting.md)
- [FAQ](docs/faq.md)
- [Architecture système](docs/architecture.md)

## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour commencer.

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

---

⭐ **N'hésitez pas à starrer ce repo si il vous a été utile !**

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

# Rendre le script exécutable
chmod +x install.sh

# Lancer l'installation interactive
sudo ./install.sh
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

## 🚀 Services Inclus

| Service | Port | Description |
|----|----|----|
| Jellyfin | 8096 | Serveur média streaming |
| Jellyseerr | 5055 | Interface requêtes média |
| Sonarr | 8989 | Gestion séries TV |
| Radarr | 7878 | Gestion films |
| Lidarr | 8686 | Gestion musique |
| Readarr | 8787 | Gestion livres |
| qBittorrent | 8080 | Client torrent |
| Prowlarr | 9696 | Indexeurs centralisés |
| FlareSolverr | 8191 | Bypass Cloudflare |
| Bazarr | 6767 | Sous-titres automatiques |

## 📖 Documentation

- [Guide d'installation détaillé](docs/installation.md)
- [Configuration des services](docs/configuration.md)
- [Guide de dépannage](docs/troubleshooting.md)
- [FAQ](docs/faq.md)

## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour commencer.

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

---

⭐ **N'hésitez pas à starrer ce repo si il vous a été utile !**

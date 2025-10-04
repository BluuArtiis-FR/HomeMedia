# 📁 Structure du Projet

Ce document explique l'organisation complète du projet HomeLab Media Server.

## 🗂️ Arborescence

```
homelab-media-server/
├── 📄 README.md                 # Documentation principale
├── 📄 LICENSE                   # Licence MIT
├── 📄 CONTRIBUTING.md           # Guide de contribution
├── 📄 STRUCTURE.md              # Ce fichier
├── 📄 .gitignore                # Fichiers à ignorer par Git
│
├── ⚙️ .env.example              # Template de configuration
├── 🐳 docker-compose.yml        # Configuration Docker par défaut
│
├── 🔧 Scripts
│   ├── install.sh               # Installation automatique complète
│   ├── generate-compose.sh      # Générateur Docker Compose modulaire
│   └── health-check.sh          # Vérification santé système
│
└── 📚 docs/                     # Documentation détaillée
    ├── quick-start.md           # 🚀 Guide démarrage rapide
    ├── installation.md          # Installation détaillée
    ├── configuration.md         # Configuration services
    ├── architecture.md          # Architecture système
    ├── troubleshooting.md       # Dépannage
    └── faq.md                   # Questions fréquentes
```

---

## 📄 Fichiers Principaux

### README.md
**Description** : Point d'entrée du projet, vue d'ensemble complète
**Contient** :
- Présentation du projet
- Installation rapide
- Liste des services
- Liens vers documentation

### LICENSE
**Description** : Licence MIT du projet
**Usage** : Définit les droits d'utilisation, modification et distribution

### CONTRIBUTING.md
**Description** : Guide pour les contributeurs
**Contient** :
- Standards de code
- Processus de Pull Request
- Convention de commits
- Comment signaler bugs/features

### .gitignore
**Description** : Liste des fichiers à ne pas versionner
**Protège** :
- Fichiers de configuration sensibles (`.env`)
- Données utilisateurs (`config/`, `media/`)
- Fichiers système

---

## ⚙️ Fichiers de Configuration

### .env.example
**Description** : Template de configuration environnement
**Variables** :
- Credentials VPN (ProtonVPN)
- Chemins des volumes
- Ports personnalisés
- PUID/PGID utilisateur

**Usage** :
```bash
cp .env.example .env
nano .env  # Modifier avec vos valeurs
```

### docker-compose.yml
**Description** : Configuration Docker Compose par défaut
**Services inclus** :
- Gluetun (VPN)
- Jellyfin, Jellyseerr
- Sonarr, Radarr
- qBittorrent, Prowlarr
- Bazarr, FlareSolverr

**Note** : Ce fichier peut être régénéré avec `generate-compose.sh`

---

## 🔧 Scripts Exécutables

### install.sh (548 lignes)
**Rôle** : Installation automatisée complète du système

**Fonctionnalités** :
1. ✅ Vérification prérequis (OS, RAM, CPU, disque)
2. ✅ Installation Docker + Docker Compose
3. ✅ Configuration pare-feu UFW
4. ✅ Installation Fail2Ban
5. ✅ Création structure dossiers
6. ✅ Configuration `.env` interactive
7. ✅ Génération `docker-compose.yml`
8. ✅ Déploiement containers
9. ✅ Vérification santé services

**Usage** :
```bash
chmod +x install.sh
sudo ./install.sh
```

**Logs** : `/var/log/homelab-install.log`

---

### generate-compose.sh (546 lignes)
**Rôle** : Générateur modulaire de docker-compose.yml

**Fonctionnalités** :
- 🎛️ Menu interactif de sélection services
- 🔄 Activation/désactivation des modules
- 📋 Configuration par défaut intelligente
- 🚀 Commandes de gestion (start/stop/status)
- 🗑️ Nettoyage complet optionnel

**Services disponibles** :
1. Jellyfin (streaming)
2. Jellyseerr (requêtes)
3. Sonarr (séries TV)
4. Radarr (films)
5. Lidarr (musique)
6. Readarr (livres)
7. qBittorrent (torrent)
8. Prowlarr (indexeurs)
9. Bazarr (sous-titres)
10. FlareSolverr (Cloudflare bypass)

**Usage** :
```bash
./generate-compose.sh
# Sélectionnez les services voulus
# Le fichier docker-compose.yml est généré automatiquement
```

---

### health-check.sh (400 lignes)
**Rôle** : Diagnostic complet du système

**Vérifications** :
- ✅ Installation Docker/Docker Compose
- ✅ Ressources système (CPU/RAM/Disque)
- ✅ État des containers Docker
- ✅ Connectivité réseau et VPN
- ✅ Ports ouverts
- ✅ Volumes Docker
- ✅ Erreurs récentes dans logs
- ✅ Recommandations maintenance

**Usage** :
```bash
./health-check.sh
```

**Exemple de sortie** :
```
✅ Docker installé: v24.0.7
✅ RAM: 8/16GB (50%)
✅ Jellyfin (jellyfin) - Running (uptime: 2h15m)
✅ VPN actif - IP externe: 185.107.56.123
```

---

## 📚 Documentation

### docs/quick-start.md ⭐
**Public** : Débutants
**Durée** : 15 minutes
**Contenu** :
- Installation express (5 min)
- Première configuration pas-à-pas (10 min)
- Premier téléchargement de test
- Vérification sécurité VPN
- Tableau de bord récapitulatif

**Parfait pour** : Déploiement rapide et premier usage

---

### docs/installation.md
**Public** : Utilisateurs avancés
**Contenu** :
- Prérequis système détaillés
- Installation automatique vs manuelle
- Configuration post-installation
- Dépannage installation
- Procédure de désinstallation

---

### docs/configuration.md
**Public** : Configuration avancée
**Contient** :
- Configuration détaillée de chaque service
- Profils de qualité optimisés
- Paramètres VPN avancés
- SSL/HTTPS avec Traefik
- Monitoring avec Portainer
- Scripts de sauvegarde

---

### docs/architecture.md
**Public** : Technique
**Contient** :
- Schéma d'architecture complet
- Flux de données
- Sécurité réseau (VPN, UFW, Fail2Ban)
- Optimisations performance
- Monitoring et logs
- Scalabilité

---

### docs/troubleshooting.md
**Public** : Résolution problèmes
**Sections** :
- Problèmes Docker
- Problèmes réseau/VPN
- Problèmes services spécifiques
- Logs et debugging
- Réinitialisation services

---

### docs/faq.md
**Public** : Questions fréquentes
**Thèmes** :
- Configuration générale
- Sécurité et VPN
- Performance
- Gestion contenu
- Accès distant

---

## 🗄️ Structure d'Exécution (Runtime)

Après installation, la structure suivante est créée :

```
/opt/homelab/
├── config/              # Configurations persistantes
│   ├── jellyfin/
│   ├── sonarr/
│   ├── radarr/
│   ├── qbittorrent/
│   ├── prowlarr/
│   ├── bazarr/
│   └── jellyseerr/
│
├── data/                # Données applicatives
│
├── downloads/           # Téléchargements en cours
│   ├── incomplete/
│   ├── movies/
│   └── tv/
│
└── media/               # Bibliothèque média finale
    ├── movies/          # Films (Radarr → Jellyfin)
    ├── tv/              # Séries TV (Sonarr → Jellyfin)
    ├── music/           # Musique (Lidarr → Jellyfin)
    └── books/           # Livres (Readarr)
```

---

## 🔐 Fichiers Sensibles (Non-versionnés)

Ces fichiers sont automatiquement ignorés par Git :

```
.env                     # Credentials VPN et configuration
config/                  # Configurations services (API keys)
data/                    # Données utilisateurs
downloads/               # Téléchargements
media/                   # Bibliothèque média
docker-compose.yml       # Peut contenir config personnalisée
*.log                    # Fichiers de logs
```

---

## 🔄 Workflow de Développement

### 1. Cloner le Projet
```bash
git clone https://github.com/BluuArtiis-FR/homelab-media-server.git
cd homelab-media-server
```

### 2. Configuration Initiale
```bash
cp .env.example .env
nano .env  # Configurer VPN
```

### 3. Installation
```bash
chmod +x *.sh
sudo ./install.sh
```

### 4. Utilisation
```bash
./health-check.sh           # Vérifier santé
docker compose logs -f      # Voir logs
./generate-compose.sh       # Reconfigurer services
```

---

## 📊 Métriques du Projet

| Composant | Lignes de Code | Complexité |
|-----------|----------------|------------|
| install.sh | 548 | Élevée |
| generate-compose.sh | 546 | Moyenne |
| health-check.sh | 400 | Moyenne |
| Documentation | ~3500 | - |
| **Total** | **~5000** | - |

---

## 🎯 Points d'Entrée Recommandés

1. **Première utilisation** → [docs/quick-start.md](docs/quick-start.md)
2. **Installation personnalisée** → [docs/installation.md](docs/installation.md)
3. **Configuration avancée** → [docs/configuration.md](docs/configuration.md)
4. **Problèmes** → [docs/troubleshooting.md](docs/troubleshooting.md)
5. **Contribuer** → [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Dernière mise à jour** : 2024
**Mainteneur** : BluuArtiis-FR
**Licence** : MIT

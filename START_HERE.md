# 🚀 COMMENCEZ ICI !

Bienvenue dans **HomeLab Media Server** ! Ce fichier vous guide pour un démarrage ultra-rapide.

---

## ⚡ Installation en 3 Étapes (5 minutes)

### Étape 1 : Cloner le Projet
```bash
git clone https://github.com/BluuArtiis-FR/homelab-media-server.git
cd homelab-media-server
```

### Étape 2 : Rendre les Scripts Exécutables
```bash
chmod +x install.sh generate-compose.sh health-check.sh
```

### Étape 3 : Installer
```bash
sudo ./install.sh
```

L'installateur va :
- ✅ Vérifier votre système
- ✅ Installer Docker
- ✅ Configurer le pare-feu
- ✅ Vous demander vos credentials ProtonVPN
- ✅ Déployer tous les services

**C'est tout !** 🎉

---

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :

- ✅ **Système** : Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- ✅ **RAM** : 4 GB minimum (8 GB recommandé)
- ✅ **CPU** : 2 cœurs minimum
- ✅ **Disque** : 50 GB libre minimum
- ✅ **VPN** : Compte ProtonVPN actif ([Créer un compte](https://protonvpn.com))

---

## 🎯 Après l'Installation

### Accédez à vos Services

Remplacez `VOTRE-IP` par l'IP de votre serveur :

| Service | URL | Description |
|---------|-----|-------------|
| **Jellyfin** | http://VOTRE-IP:8096 | Votre Netflix personnel |
| **Jellyseerr** | http://VOTRE-IP:5055 | Demander films/séries |
| **Sonarr** | http://VOTRE-IP:8989 | Gérer les séries |
| **Radarr** | http://VOTRE-IP:7878 | Gérer les films |
| **qBittorrent** | http://VOTRE-IP:8080 | Téléchargement |
| **Prowlarr** | http://VOTRE-IP:9696 | Indexeurs torrent |

### Configuration Rapide (15 minutes)

Suivez le **[Guide de Démarrage Rapide](docs/quick-start.md)** qui vous explique :

1. ✅ Configuration Jellyfin (2 min)
2. ✅ Configuration Prowlarr + indexeurs (3 min)
3. ✅ Configuration Sonarr (2 min)
4. ✅ Configuration Radarr (2 min)
5. ✅ Sécurisation qBittorrent (1 min)
6. ✅ Configuration Jellyseerr (2 min)
7. ✅ Premier téléchargement de test (3 min)

---

## 🛠️ Commandes Utiles

### Avec Make (Recommandé)

```bash
make help          # Voir toutes les commandes disponibles
make status        # Voir l'état des services
make logs          # Voir tous les logs
make health        # Vérifier la santé du système
make urls          # Afficher les URLs des services
make update        # Mettre à jour les services
```

### Avec Docker Compose

```bash
docker compose ps              # État des services
docker compose logs -f         # Suivre les logs
docker compose restart sonarr  # Redémarrer un service
docker compose down            # Arrêter tout
docker compose up -d           # Démarrer tout
```

### Scripts Dédiés

```bash
./health-check.sh      # Diagnostic complet
./generate-compose.sh  # Reconfigurer les services
```

---

## 🔒 Vérifier la Sécurité VPN

**IMPORTANT** : Vérifiez que le VPN fonctionne correctement

```bash
# Avec Make
make check-vpn

# Ou manuellement
docker exec gluetun wget -qO- https://api.ipify.org  # IP via VPN
curl https://api.ipify.org                            # Votre vraie IP
```

**Les deux IPs DOIVENT être différentes !** ✅

---

## 📚 Documentation Complète

| Document | Quand l'utiliser |
|----------|------------------|
| **[Quick Start](docs/quick-start.md)** | 🚀 Démarrage immédiat (15 min) |
| [Installation](docs/installation.md) | 🔧 Installation manuelle détaillée |
| [Configuration](docs/configuration.md) | ⚙️ Paramètres avancés |
| [Architecture](docs/architecture.md) | 🏗️ Comprendre le système |
| [Troubleshooting](docs/troubleshooting.md) | 🐛 Résoudre les problèmes |
| [FAQ](docs/faq.md) | ❓ Questions fréquentes |
| [Structure](STRUCTURE.md) | 📁 Organisation du projet |
| [Contributing](CONTRIBUTING.md) | 🤝 Contribuer au projet |

---

## 🎬 Votre Premier Téléchargement

1. **Ouvrez Jellyseerr** : http://VOTRE-IP:5055
2. **Recherchez** une série (ex: "Breaking Bad")
3. **Cliquez** sur "Demander"
4. **Patientez** quelques minutes
5. **Regardez** dans Jellyfin !

Le système fait tout automatiquement :
- Jellyseerr → Sonarr
- Sonarr → Prowlarr (recherche)
- Prowlarr → qBittorrent (téléchargement via VPN)
- qBittorrent → Télécharge le fichier
- Sonarr → Renomme et organise
- Bazarr → Télécharge les sous-titres
- Jellyfin → Détecte automatiquement

---

## ❓ Problèmes Courants

### Docker n'est pas installé
```bash
sudo ./install.sh  # Le script installe Docker automatiquement
```

### Permissions refusées
```bash
sudo chown -R $USER:$USER /opt/homelab
```

### Ports déjà utilisés
```bash
# Modifier les ports dans .env
nano .env
# Puis redémarrer
docker compose down && docker compose up -d
```

### VPN ne fonctionne pas
```bash
# Vérifier les credentials dans .env
nano .env
# Redémarrer Gluetun
docker compose restart gluetun qbittorrent prowlarr
```

### Service ne démarre pas
```bash
# Voir les logs du service
docker compose logs -f nom-du-service
# Exemple
docker compose logs -f jellyfin
```

---

## 🆘 Besoin d'Aide ?

1. **Consultez** le [Guide de Dépannage](docs/troubleshooting.md)
2. **Lancez** le diagnostic : `./health-check.sh`
3. **Vérifiez** les logs : `docker compose logs -f`
4. **Ouvrez** une [Issue GitHub](https://github.com/BluuArtiis-FR/homelab-media-server/issues)

---

## 🎯 Prochaines Étapes

Une fois votre serveur opérationnel :

1. ✅ **Ajoutez plus d'indexeurs** dans Prowlarr
2. ✅ **Configurez Bazarr** pour les sous-titres automatiques
3. ✅ **Créez des comptes utilisateurs** dans Jellyfin
4. ✅ **Configurez Lidarr** pour la musique (optionnel)
5. ✅ **Configurez Readarr** pour les livres (optionnel)
6. ✅ **Mettez en place un reverse proxy** pour HTTPS

Consultez le [Guide de Configuration Avancée](docs/configuration.md) !

---

## 🌟 Contribuer

Vous aimez ce projet ? Vous pouvez :

- ⭐ **Starrer** le repository GitHub
- 🐛 **Signaler** des bugs
- 💡 **Proposer** des améliorations
- 🤝 **Contribuer** du code

Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour commencer !

---

## 📊 Résumé Visuel

```
┌─────────────────────────────────────────────────────────────┐
│                 HOMELAB MEDIA SERVER                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🎬 Jellyfin         📱 Jellyseerr      📺 Sonarr          │
│     (Streaming)         (Requêtes)         (Séries)        │
│                                                             │
│  🎞️  Radarr          ⬇️  qBittorrent     🔍 Prowlarr       │
│     (Films)            (Téléchargement)    (Indexeurs)     │
│                                                             │
│  📝 Bazarr           🔒 Gluetun                            │
│     (Sous-titres)       (VPN ProtonVPN)                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                    ↓
         [Bibliothèque Média Organisée]
                    ↓
              [Streaming 1080p]
```

---

## ✅ Checklist de Démarrage

- [ ] Prérequis système vérifiés
- [ ] Compte ProtonVPN créé
- [ ] Projet cloné
- [ ] `sudo ./install.sh` exécuté
- [ ] Services accessibles
- [ ] Jellyfin configuré
- [ ] Prowlarr + indexeurs configurés
- [ ] Sonarr/Radarr configurés
- [ ] qBittorrent sécurisé (VPN vérifié)
- [ ] Jellyseerr configuré
- [ ] Premier téléchargement testé
- [ ] Tout fonctionne ! 🎉

---

**Félicitations ! Vous avez maintenant votre propre serveur média automatisé et sécurisé !** 🚀

Pour toute question : [Documentation Complète](README.md) | [Support](https://github.com/BluuArtiis-FR/homelab-media-server/issues)

# 🔄 Guide de Réinstallation Complète de la VM

## 📋 Table des matières
1. [Sauvegarde des données](#sauvegarde)
2. [Nettoyage complet de la VM](#nettoyage)
3. [Réinstallation depuis zéro](#reinstallation)
4. [Vérification post-installation](#verification)
5. [Configuration des applications](#configuration)

---

## 💾 1. Sauvegarde des données (optionnel) {#sauvegarde}

Si vous avez des données à conserver (fichiers médias, configurations) :

```bash
# Sauvegarder les fichiers médias
sudo tar -czf ~/backup-media-$(date +%Y%m%d).tar.gz /opt/homelab/media/

# Sauvegarder la configuration .env
cp /home/flo/HomeMedia/.env ~/backup-env-$(date +%Y%m%d)

# Sauvegarder les configurations Jellyfin (bibliothèques, utilisateurs)
sudo tar -czf ~/backup-jellyfin-$(date +%Y%m%d).tar.gz /opt/homelab/config/jellyfin/
```

---

## 🧹 2. Nettoyage complet de la VM {#nettoyage}

### Étape 2.1 : Arrêt et suppression des containers Docker

```bash
# Se placer dans le répertoire du projet
cd /home/flo/HomeMedia

# Arrêter tous les containers
docker compose down

# Supprimer tous les containers (même ceux non gérés par compose)
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

# Supprimer toutes les images
docker rmi $(docker images -q) 2>/dev/null

# Supprimer tous les volumes
docker volume rm $(docker volume ls -q) 2>/dev/null

# Supprimer tous les réseaux personnalisés
docker network prune -f

# Nettoyage complet du système Docker
docker system prune -a --volumes -f
```

### Étape 2.2 : Suppression des services locaux (installés hors Docker)

```bash
# Vérifier les services installés localement
sudo systemctl list-units --type=service | grep -E 'jellyfin|sonarr|radarr|prowlarr'

# Arrêter et désactiver les services locaux
sudo systemctl stop jellyfin sonarr radarr prowlarr jellyseerr qbittorrent-nox 2>/dev/null
sudo systemctl disable jellyfin sonarr radarr prowlarr jellyseerr qbittorrent-nox 2>/dev/null

# Désinstaller les paquets (si installés)
sudo apt remove --purge jellyfin sonarr radarr prowlarr jellyseerr qbittorrent-nox -y
sudo apt autoremove -y
```

### Étape 2.3 : Suppression des fichiers et dossiers

```bash
# Supprimer le répertoire du projet
rm -rf /home/flo/HomeMedia

# Supprimer les données d'installation
sudo rm -rf /opt/homelab

# Supprimer les configurations résiduelles
sudo rm -rf /etc/jellyfin /etc/sonarr /etc/radarr /var/lib/jellyfin /var/lib/sonarr /var/lib/radarr
```

### Étape 2.4 : Nettoyage du firewall (optionnel)

```bash
# Lister les règles UFW
sudo ufw status numbered

# Supprimer les règles liées au projet (adapter les numéros)
# Exemple : sudo ufw delete 1

# Ou réinitialiser complètement UFW
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable
```

### Étape 2.5 : Vérification finale

```bash
# Vérifier qu'aucun port n'est utilisé
sudo netstat -tulpn | grep -E '8096|8989|7878|9696|6767|5055|8080'

# Vérifier qu'aucun container ne tourne
docker ps -a

# Vérifier l'espace disque libéré
df -h
```

---

## 🚀 3. Réinstallation depuis zéro {#reinstallation}

### Étape 3.1 : Mise à jour du système

```bash
# Mettre à jour les paquets
sudo apt update && sudo apt upgrade -y

# Redémarrer si nécessaire
sudo reboot
```

### Étape 3.2 : Clonage du projet

```bash
# Se placer dans le répertoire home
cd ~

# Cloner le dépôt (ou télécharger depuis GitHub)
git clone https://github.com/BluuArtiis-FR/HomeMedia.git

# Si vous n'avez pas git, télécharger l'archive
# wget https://github.com/BluuArtiis-FR/HomeMedia/archive/main.zip
# unzip main.zip
# mv HomeMedia-main HomeMedia

# Entrer dans le répertoire
cd HomeMedia
```

### Étape 3.3 : Configuration du fichier .env

```bash
# Copier l'exemple de configuration
cp .env.example .env

# Éditer le fichier .env avec vos paramètres
nano .env
```

**Configuration minimale requise :**

```bash
# === VPN ProtonVPN ===
OPENVPN_USER=votre_username_protonvpn
OPENVPN_PASSWORD=votre_password_protonvpn

# === Chemins ===
INSTALL_DIR=/opt/homelab

# === Ports (par défaut, pas de conflit) ===
JELLYFIN_PORT=8096
SONARR_PORT=8989
RADARR_PORT=7878
PROWLARR_PORT=9696
BAZARR_PORT=6767
JELLYSEERR_PORT=5055
QBITTORRENT_PORT=8080
FLARESOLVERR_PORT=8191

# === Timezone ===
TZ=Europe/Paris

# === PUID/PGID (utiliser 'id' pour obtenir vos valeurs) ===
PUID=1000
PGID=1000
```

**💡 Astuce :** Pour obtenir votre PUID et PGID :
```bash
id
# Résultat : uid=1000(flo) gid=1000(flo) ...
```

### Étape 3.4 : Installation automatique

```bash
# Rendre le script exécutable
chmod +x install.sh

# Lancer l'installation
sudo ./install.sh
```

**L'installation va :**
1. ✅ Installer Docker et Docker Compose
2. ✅ Créer la structure de dossiers (incluant `/opt/homelab/media/anime`)
3. ✅ Configurer le firewall (UFW)
4. ✅ Configurer Fail2Ban
5. ✅ Télécharger et démarrer tous les containers

**Durée estimée :** 10-15 minutes (selon votre connexion)

### Étape 3.5 : Vérification du démarrage

```bash
# Vérifier que tous les containers sont démarrés
docker compose ps

# Vérifier les logs
docker compose logs

# Vérifier le VPN
docker exec gluetun wget -qO- ifconfig.me
```

**✅ Tous les containers doivent être "Up" et "healthy"**

---

## ✔️ 4. Vérification post-installation {#verification}

### Étape 4.1 : Test d'accès aux interfaces web

Ouvrir un navigateur et vérifier l'accès à :

- **Jellyfin** : http://VOTRE_IP:8096
- **Sonarr** : http://VOTRE_IP:8989
- **Radarr** : http://VOTRE_IP:7878
- **Prowlarr** : http://VOTRE_IP:9696
- **Bazarr** : http://VOTRE_IP:6767
- **Jellyseerr** : http://VOTRE_IP:5055
- **qBittorrent** : http://VOTRE_IP:8080

### Étape 4.2 : Vérification du VPN

```bash
# IP via VPN (Gluetun)
docker exec gluetun wget -qO- ifconfig.me

# IP réelle de la VM
wget -qO- ifconfig.me
```

**Les deux IPs doivent être différentes** ✅

### Étape 4.3 : Vérification de la structure des dossiers

```bash
# Lister la structure
tree -L 3 /opt/homelab/

# Vérifier les permissions
ls -lah /opt/homelab/
```

**Vous devriez voir :**
```
/opt/homelab/
├── config/
│   ├── bazarr/
│   ├── jellyfin/
│   ├── jellyseerr/
│   ├── prowlarr/
│   ├── qbittorrent/
│   ├── radarr/
│   └── sonarr/
├── downloads/
└── media/
    ├── anime/      ← NOUVEAU
    ├── books/
    ├── movies/
    ├── music/
    └── tv/
```

### Étape 4.4 : Health Check complet

```bash
# Lancer le script de vérification
./health-check.sh

# Ou utiliser le Makefile
make health
```

---

## ⚙️ 5. Configuration des applications {#configuration}

### Étape 5.1 : Configuration initiale de Jellyfin

1. Accéder à http://VOTRE_IP:8096
2. Suivre l'assistant de configuration
3. Créer un compte administrateur

**Création des bibliothèques :**

- **Films** : `/movies` (type : Films)
- **Séries TV** : `/tv` (type : Séries TV)
- **Anime** : `/anime` (type : Séries TV avec bibliothèque séparée)
- **Musique** : `/music` (type : Musique)

### Étape 5.2 : Configuration de qBittorrent

1. Accéder à http://VOTRE_IP:8080
2. Connexion par défaut :
   - **Username** : `admin`
   - **Password** : `adminadmin`
3. **IMPORTANT** : Changer le mot de passe immédiatement
   - Outils → Options → Web UI → Authentification
4. Configurer le répertoire de téléchargement :
   - Téléchargements → Options → Chemin par défaut : `/downloads`

### Étape 5.3 : Configuration de Prowlarr

1. Accéder à http://VOTRE_IP:9696
2. Configurer l'authentification (Settings → General → Security)
3. Ajouter des indexers (Indexers → Add Indexer)
   - Exemples : YGGTorrent, Torrent9, 1337x, RARBG, etc.

**Configuration FlareSolverr (pour contourner Cloudflare) :**
- Settings → Indexers → FlareSolverr
- Tags : `flaresolverr`
- Host : `http://flaresolverr:8191`

### Étape 5.4 : Connexion Prowlarr → Radarr/Sonarr

**IMPORTANT** : Utiliser les **noms de services Docker**, pas `localhost` !

#### Ajouter Radarr dans Prowlarr :
1. Prowlarr → Settings → Apps → Add Application → Radarr
2. Configuration :
   - **Name** : `Radarr`
   - **Sync Level** : `Full Sync`
   - **Prowlarr Server** : `http://localhost:9696`
   - **Radarr Server** : `http://radarr:7878` ← **NOM DU SERVICE**
   - **API Key** : Récupérer dans Radarr → Settings → General → API Key
3. Test → Save

#### Ajouter Sonarr dans Prowlarr :
1. Prowlarr → Settings → Apps → Add Application → Sonarr
2. Configuration :
   - **Name** : `Sonarr`
   - **Sync Level** : `Full Sync`
   - **Prowlarr Server** : `http://localhost:9696`
   - **Sonarr Server** : `http://sonarr:8989` ← **NOM DU SERVICE**
   - **API Key** : Récupérer dans Sonarr → Settings → General → API Key
3. Test → Save

**🔍 Vérification :** Les indexers ajoutés dans Prowlarr doivent maintenant apparaître automatiquement dans Radarr et Sonarr !

### Étape 5.5 : Configuration de Radarr

1. Accéder à http://VOTRE_IP:7878
2. Settings → Media Management :
   - **Root Folder** : `/movies`
3. Settings → Download Clients → Add → qBittorrent :
   - **Name** : `qBittorrent`
   - **Host** : `qbittorrent` ← **NOM DU SERVICE**
   - **Port** : `8080`
   - **Username** : `admin`
   - **Password** : Votre mot de passe qBittorrent
   - **Category** : `radarr`
4. Test → Save

### Étape 5.6 : Configuration de Sonarr

1. Accéder à http://VOTRE_IP:8989
2. Settings → Media Management :
   - **Root Folder 1** : `/tv` (Séries TV)
   - **Root Folder 2** : `/anime` (Anime) ← **NOUVEAU**
3. Settings → Download Clients → Add → qBittorrent :
   - **Name** : `qBittorrent`
   - **Host** : `qbittorrent` ← **NOM DU SERVICE**
   - **Port** : `8080`
   - **Username** : `admin`
   - **Password** : Votre mot de passe qBittorrent
   - **Category** : `sonarr`
4. Test → Save

### Étape 5.7 : Configuration de Bazarr

1. Accéder à http://VOTRE_IP:6767
2. Settings → Sonarr :
   - **Address** : `http://sonarr:8989`
   - **API Key** : Clé API de Sonarr
3. Settings → Radarr :
   - **Address** : `http://radarr:7878`
   - **API Key** : Clé API de Radarr
4. Settings → Languages :
   - Ajouter Français (French)
5. Settings → Providers :
   - Ajouter OpenSubtitles, Subscene, etc.

### Étape 5.8 : Configuration de Jellyseerr

1. Accéder à http://VOTRE_IP:5055
2. Connecter avec Jellyfin :
   - **Jellyfin URL** : `http://jellyfin:8096`
   - Connexion avec compte admin Jellyfin
3. Ajouter Radarr :
   - **Server** : `http://radarr:7878`
   - **API Key** : Clé API de Radarr
   - **Root Folder** : `/movies`
4. Ajouter Sonarr :
   - **Server** : `http://sonarr:8989`
   - **API Key** : Clé API de Sonarr
   - **Root Folder** : `/tv` ou `/anime`

---

## 🎯 Récapitulatif des URLs internes Docker

| Service | URL Externe (Navigateur) | URL Interne (Docker) |
|---------|--------------------------|----------------------|
| Jellyfin | http://VOTRE_IP:8096 | http://jellyfin:8096 |
| Sonarr | http://VOTRE_IP:8989 | http://sonarr:8989 |
| Radarr | http://VOTRE_IP:7878 | http://radarr:7878 |
| Prowlarr | http://VOTRE_IP:9696 | http://prowlarr:9696 |
| Bazarr | http://VOTRE_IP:6767 | http://bazarr:6767 |
| Jellyseerr | http://VOTRE_IP:5055 | http://jellyseerr:5055 |
| qBittorrent | http://VOTRE_IP:8080 | http://qbittorrent:8080 |
| FlareSolverr | http://VOTRE_IP:8191 | http://flaresolverr:8191 |
| Gluetun | - | http://gluetun:8000 |

**⚠️ RÈGLE IMPORTANTE :**
- **Navigateur → Services** : Utiliser `http://IP:PORT`
- **Service → Service** : Utiliser `http://nom_service:port_interne`

---

## 🐛 Dépannage

### Problème : Containers qui ne démarrent pas

```bash
# Vérifier les logs
docker compose logs SERVICE_NAME

# Exemples
docker compose logs gluetun
docker compose logs radarr
```

### Problème : Erreur "Name does not resolve"

**Cause** : Utilisation de `localhost` au lieu du nom du service Docker.

**Solution** : Toujours utiliser `http://nom_service:port` pour les communications inter-containers.

### Problème : VPN ne fonctionne pas

```bash
# Vérifier les logs Gluetun
docker compose logs gluetun

# Vérifier les variables VPN dans .env
grep -E 'OPENVPN|VPN_SERVICE_PROVIDER' .env

# Redémarrer Gluetun
docker compose restart gluetun
```

### Problème : Permissions denied

```bash
# Vérifier les permissions
ls -lah /opt/homelab/

# Corriger les permissions
sudo chown -R $(id -u):$(id -g) /opt/homelab/
```

### Problème : Port déjà utilisé

```bash
# Identifier le processus utilisant le port
sudo netstat -tulpn | grep :8096

# Arrêter le service local
sudo systemctl stop jellyfin

# Ou modifier le port dans .env
nano .env
# JELLYFIN_PORT=8097
```

---

## 📚 Commandes utiles

```bash
# Redémarrer tous les services
docker compose restart

# Arrêter tous les services
docker compose down

# Démarrer tous les services
docker compose up -d

# Voir les logs en temps réel
docker compose logs -f

# Mettre à jour les images
docker compose pull
docker compose up -d

# Vérifier l'utilisation des ressources
docker stats

# Vérifier l'espace disque
df -h
du -sh /opt/homelab/*
```

---

## ✅ Checklist finale

- [ ] Tous les containers sont démarrés (`docker compose ps`)
- [ ] VPN fonctionne (IPs différentes)
- [ ] Accès aux 8 interfaces web
- [ ] Jellyfin configuré avec 4 bibliothèques (Films, Séries, Anime, Musique)
- [ ] qBittorrent accessible et mot de passe changé
- [ ] Prowlarr connecté à Radarr et Sonarr avec les **bons noms de services**
- [ ] Indexers visibles dans Radarr et Sonarr
- [ ] Bazarr connecté à Radarr et Sonarr
- [ ] Jellyseerr connecté à Jellyfin, Radarr et Sonarr
- [ ] Test de téléchargement d'un film ou série

---

## 🎉 Installation terminée !

Votre HomeLab Media Server est maintenant opérationnel avec :
- ✅ VPN intégré pour la confidentialité
- ✅ Gestion automatique des films, séries et anime
- ✅ Sous-titres automatiques
- ✅ Demandes utilisateurs via Jellyseerr
- ✅ Sécurité renforcée (Fail2Ban, UFW)

**Profitez de votre serveur média ! 🍿**

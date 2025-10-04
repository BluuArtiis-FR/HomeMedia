# 🚀 Installation Pas-à-Pas - Guide Complet

**Guide détaillé pour installer HomeLab Media Server sur Debian 12 sans erreur**

---

## 📋 Vue d'Ensemble

**Durée totale** : 20-30 minutes
**Difficulté** : Facile (copier-coller des commandes)
**Prérequis** : VM Debian 12 installée avec SSH

---

## 🎯 Étapes Principales

1. [Nettoyer l'installation précédente](#étape-1--nettoyer-linstallation-précédente) (si nécessaire)
2. [Préparer le système Debian](#étape-2--préparer-le-système-debian)
3. [Cloner le projet](#étape-3--cloner-le-projet)
4. [Installer automatiquement](#étape-4--installation-automatique)
5. [Vérifier le déploiement](#étape-5--vérifier-le-déploiement)
6. [Configurer les services](#étape-6--configurer-les-services)

---

## 🧹 Étape 1 : Nettoyer l'Installation Précédente

**Si vous avez déjà tenté une installation**, nettoyez d'abord :

### 1.1 Arrêter et Supprimer les Containers Docker

```bash
# Aller dans le dossier du projet (si existe)
cd ~/HomeMedia

# Arrêter tous les containers
docker compose down -v 2>/dev/null || true

# Supprimer tous les containers
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Supprimer toutes les images (optionnel, économise de l'espace)
docker rmi $(docker images -q) 2>/dev/null || true

# Nettoyer Docker complètement
docker system prune -a -f --volumes
```

### 1.2 Supprimer les Dossiers de Données

```bash
# Supprimer les données HomeLab (ATTENTION: perte de données!)
sudo rm -rf /opt/homelab

# Supprimer le projet cloné
cd ~
rm -rf HomeMedia
```

### 1.3 Vérifier que Tout est Clean

```bash
# Vérifier qu'il n'y a plus de containers
docker ps -a

# Vérifier que le dossier n'existe plus
ls -la /opt/homelab  # Devrait afficher "No such file or directory"
ls -la ~/HomeMedia   # Devrait afficher "No such file or directory"
```

✅ **Checkpoint 1** : Système propre, prêt pour installation fraîche

---

## 🐧 Étape 2 : Préparer le Système Debian

### 2.1 Mettre à Jour le Système

```bash
# Mise à jour de la liste des paquets
sudo apt update

# Mise à jour du système
sudo apt upgrade -y
```

**Durée** : 2-5 minutes

### 2.2 Installer les Outils de Base

```bash
# Installer les outils nécessaires
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    net-tools \
    ca-certificates \
    gnupg \
    lsb-release
```

### 2.3 Vérifier que Sudo Fonctionne

```bash
# Tester sudo
sudo whoami
# Devrait afficher: root

# Si erreur "user is not in the sudoers file"
# Exécuter:
su -
apt install sudo
usermod -aG sudo flo  # Remplacez "flo" par votre nom d'utilisateur
exit
# Puis déconnectez-vous et reconnectez-vous en SSH
```

### 2.4 Configurer IP Statique (Recommandé)

```bash
# Identifier votre interface réseau
ip a
# Notez le nom (ex: ens18, eth0, enp0s3)

# Éditer la configuration réseau
sudo nano /etc/network/interfaces
```

**Contenu à ajouter** (adaptez selon votre réseau) :

```bash
# Interface loopback
auto lo
iface lo inet loopback

# Interface réseau (ADAPTEZ LE NOM!)
auto ens18
iface ens18 inet static
    address 192.168.1.100      # CHANGEZ cette IP
    netmask 255.255.255.0
    gateway 192.168.1.1        # IP de votre box/routeur
    dns-nameservers 8.8.8.8 8.8.4.4
```

**Appliquer** :

```bash
# Redémarrer le réseau
sudo systemctl restart networking

# Ou redémarrer la VM
sudo reboot

# Après redémarrage, vérifier
ip a
ping 8.8.8.8
```

✅ **Checkpoint 2** : Système à jour, outils installés, réseau configuré

---

## 📥 Étape 3 : Cloner le Projet

### 3.1 Cloner le Repository GitHub

```bash
# Se placer dans le home
cd ~

# Cloner le projet
git clone https://github.com/BluuArtiis-FR/HomeMedia.git

# Aller dans le dossier
cd HomeMedia

# Vérifier que tout est là
ls -la
```

**Vous devriez voir** :
```
.env.example
.gitignore
CHANGELOG.md
CONTRIBUTING.md
DEBIAN_12_GUIDE.md
docker-compose.yml
generate-compose.sh
GUIDE_DEPLOIEMENT_VM.md
health-check.sh
install.sh
LICENSE
Makefile
README.md
START_HERE.md
STRUCTURE.md
VALIDATION_REPORT.md
docs/
```

### 3.2 Rendre les Scripts Exécutables

```bash
# Rendre tous les scripts exécutables
chmod +x install.sh generate-compose.sh health-check.sh

# Vérifier les permissions
ls -la *.sh
# Devrait afficher: -rwxr-xr-x pour chaque fichier
```

✅ **Checkpoint 3** : Projet cloné avec tous les fichiers

---

## 🚀 Étape 4 : Installation Automatique

### 4.1 Préparer les Credentials ProtonVPN

**AVANT de lancer l'installation, préparez vos credentials :**

1. Allez sur : https://account.protonvpn.com/login
2. Connectez-vous
3. Account → OpenVPN/IKEv2 Username
4. Notez :
   - **Username** : `quelquechose+pmp`
   - **Password** : Cliquez sur 👁️ pour afficher

**Gardez ces informations sous la main !**

### 4.2 Lancer l'Installation

```bash
# Se placer dans le dossier du projet
cd ~/HomeMedia

# Lancer l'installation automatique
sudo ./install.sh
```

### 4.3 Suivre l'Installation

**Le script va afficher :**

```
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║        🏠 HomeLab Media Server - Installation 🏠        ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

▶ Vérification du système d'exploitation...
ℹ️  OS détecté: Debian GNU/Linux 12 (bookworm)
✅ OS supporté

▶ Vérification des ressources système...
✅ RAM: 8GB
✅ CPU: 4 cœurs
✅ Espace disque: 50GB disponible

⚠️  Cette installation va modifier votre système:
  - Installation de Docker et Docker Compose
  - Configuration du pare-feu UFW
  - Installation de Fail2Ban
  - Création de dossiers dans /opt/homelab

Continuer ? (y/N):
```

**Tapez :** `y` puis Entrée

**Le script va continuer :**

```
▶ Installation de Docker...
✅ Docker installé avec succès

▶ Vérification de Docker Compose...
✅ Docker Compose installé: v2.24.5

▶ Configuration du pare-feu UFW...
✅ Pare-feu configuré

▶ Installation de Fail2Ban...
✅ Fail2Ban installé et configuré

▶ Création de la structure de dossiers...
✅ Structure de dossiers créée: /opt/homelab

▶ Configuration du fichier .env...
ℹ️  Template .env créé

📝 Configuration VPN ProtonVPN
Nom d'utilisateur ProtonVPN:
```

### 4.4 Entrer vos Credentials VPN

**Quand demandé :**

```
Nom d'utilisateur ProtonVPN: [COLLEZ VOTRE USERNAME ICI]
Mot de passe ProtonVPN: [COLLEZ VOTRE PASSWORD ICI]
```

**Le script continue :**

```
✅ Fichier .env configuré

▶ Génération du docker-compose.yml...
✅ docker-compose.yml généré

▶ Déploiement des containers Docker...
ℹ️  Téléchargement des images Docker...
[+] Pulling gluetun      ...done
[+] Pulling jellyfin     ...done
[+] Pulling sonarr       ...done
[...]

ℹ️  Démarrage des services...
✅ Containers déployés

▶ Vérification de la santé des services...
ℹ️  Status des containers:
NAME           IMAGE                  STATUS
gluetun        qmcgaw/gluetun        Up 10 seconds
jellyfin       jellyfin/jellyfin     Up 8 seconds
sonarr         linuxserver/sonarr    Up 7 seconds
[...]

═══════════════════════════════════════════════════
✅ Installation terminée avec succès !
═══════════════════════════════════════════════════
```

**Durée totale** : 5-10 minutes

✅ **Checkpoint 4** : Installation terminée avec succès

---

## 🔍 Étape 5 : Vérifier le Déploiement

### 5.1 Vérifier Docker

```bash
# Version Docker
docker --version
# Devrait afficher: Docker version 24.x.x

# Version Docker Compose
docker compose version
# Devrait afficher: Docker Compose version v2.x.x
```

### 5.2 Vérifier les Containers

```bash
# Lister tous les containers
docker compose ps

# Devrait afficher quelque chose comme:
# NAME           STATUS
# gluetun        Up 2 minutes
# jellyfin       Up 2 minutes
# jellyseerr     Up 2 minutes
# sonarr         Up 2 minutes
# radarr         Up 2 minutes
# qbittorrent    Up 2 minutes
# prowlarr       Up 2 minutes
# bazarr         Up 2 minutes
# flaresolverr   Up 2 minutes
```

### 5.3 Vérifier le VPN (CRITIQUE!)

```bash
# IP via VPN (doit être ProtonVPN)
docker exec gluetun wget -qO- https://api.ipify.org
# Ex: 185.107.56.123 (IP ProtonVPN)

# Votre vraie IP (pour comparer)
curl https://api.ipify.org
# Ex: 192.168.1.100 (votre IP locale)
```

**Les deux IPs DOIVENT être différentes !**

- ✅ **IPs différentes** = VPN fonctionne correctement
- ❌ **IPs identiques** = Problème VPN (voir troubleshooting)

### 5.4 Health Check Complet

```bash
# Lancer le diagnostic complet
./health-check.sh
```

**Exemple de sortie** :

```
╔══════════════════════════════════════════════════════╗
║     🏥 HomeLab Media Server - Health Check 🏥       ║
╚══════════════════════════════════════════════════════╝

▶ Vérification Docker
✅ Docker installé: v24.0.7
✅ Docker Compose: v2.24.5

▶ Ressources Système
  CPU: 4 cœurs - 25.3% utilisé
✅ RAM: 4/8GB (50%)
✅ Disque: 35% utilisé - 39GB disponible

▶ État des Services Docker
✅ VPN Container (gluetun) - Running (uptime: 5m)
✅ Serveur Média (jellyfin) - Running (uptime: 5m)
✅ Interface Requêtes (jellyseerr) - Running (uptime: 5m)
✅ Gestion Séries (sonarr) - Running (uptime: 5m)
✅ Gestion Films (radarr) - Running (uptime: 5m)
✅ Client Torrent (qbittorrent) - Running (uptime: 5m)
✅ Indexeurs (prowlarr) - Running (uptime: 5m)
✅ Sous-titres (bazarr) - Running (uptime: 5m)
✅ Bypass Cloudflare (flaresolverr) - Running (uptime: 5m)

📊 Résumé: 9 OK | 0 KO

▶ Connectivité Réseau
✅ VPN actif - IP externe: 185.107.56.123
✅ Connectivité Internet OK
```

### 5.5 Trouver l'IP de votre VM

```bash
# Afficher l'IP
ip a | grep "inet " | grep -v 127.0.0.1
# Ex: inet 192.168.1.100/24
```

**Notez cette IP** : `192.168.1.100` (exemple)

✅ **Checkpoint 5** : Tous les services sont démarrés et le VPN fonctionne

---

## 🌐 Étape 6 : Accéder aux Services

### 6.1 URLs des Services

Remplacez `192.168.1.100` par **l'IP de votre VM** :

| Service | URL | Description |
|---------|-----|-------------|
| **Jellyfin** | http://192.168.1.100:8096 | Serveur média (votre Netflix) |
| **Jellyseerr** | http://192.168.1.100:5055 | Demander films/séries |
| **Sonarr** | http://192.168.1.100:8989 | Gérer les séries TV |
| **Radarr** | http://192.168.1.100:7878 | Gérer les films |
| **qBittorrent** | http://192.168.1.100:8080 | Téléchargement |
| **Prowlarr** | http://192.168.1.100:9696 | Indexeurs torrent |
| **Bazarr** | http://192.168.1.100:6767 | Sous-titres |

### 6.2 Tester l'Accès

**Depuis votre PC, ouvrez un navigateur** :

```
http://IP-DE-VOTRE-VM:8096
```

**Vous devriez voir** : Page d'accueil Jellyfin avec l'assistant de configuration

✅ **Checkpoint 6** : Tous les services sont accessibles

---

## ⚙️ Étape 7 : Configuration des Services (15 min)

### 7.1 Jellyfin (2 minutes)

1. Ouvrir : http://IP-VM:8096
2. **Langue** : Français
3. **Créer un compte admin** :
   - Nom : `admin`
   - Mot de passe : [choisir un mot de passe fort]
4. **Bibliothèques média** :
   - Films : `/media/movies`
   - Séries : `/media/tv`
5. **Terminer** l'assistant

### 7.2 Prowlarr (3 minutes)

1. Ouvrir : http://IP-VM:9696
2. **Settings → General → Security**
   - Authentification : Forms (Login Page)
   - Nom d'utilisateur : `admin`
   - Mot de passe : [choisir]
3. **Indexers → Add Indexer**
   - Rechercher "YGGTorrent", "1337x", "ThePirateBay"
   - Ajouter 2-3 indexeurs
4. **Pour les indexeurs Cloudflare** :
   - Settings → Indexers → FlareSolverr
   - Tags : `flaresolverr`
   - URL : `http://flaresolverr:8191`

### 7.3 Sonarr (2 minutes)

1. Ouvrir : http://IP-VM:8989
2. **Settings → Indexers**
   - Les indexeurs Prowlarr apparaissent automatiquement
3. **Settings → Download Clients → Add → qBittorrent**
   - Host : `gluetun`
   - Port : `8080`
   - Username : `admin`
   - Password : `adminadmin`
   - Category : `tv-sonarr`
4. **Settings → Media Management**
   - Root Folder : `/tv`
   - Rename Episodes : ✅

### 7.4 Radarr (2 minutes)

1. Ouvrir : http://IP-VM:7878
2. **Configuration identique à Sonarr** :
   - Download Client : qBittorrent sur `gluetun:8080`
   - Category : `movies-radarr`
   - Root Folder : `/movies`

### 7.5 qBittorrent (1 minute)

1. Ouvrir : http://IP-VM:8080
2. **Login** :
   - Username : `admin`
   - Password : `adminadmin`
3. **Changer le mot de passe** :
   - Tools → Options → Web UI
   - New password : [choisir un mot de passe fort]
4. **Vérifier VPN** :
   - Tools → Options → Advanced
   - Network Interface : `tun0`

### 7.6 Jellyseerr (2 minutes)

1. Ouvrir : http://IP-VM:5055
2. **Se connecter avec Jellyfin** :
   - Jellyfin URL : `http://jellyfin:8096`
   - Email/Username : votre compte Jellyfin
   - Password : votre mot de passe Jellyfin
3. **Ajouter Sonarr** :
   - URL : `http://sonarr:8989`
   - API Key : (copier depuis Sonarr → Settings → General)
4. **Ajouter Radarr** :
   - URL : `http://radarr:7878`
   - API Key : (copier depuis Radarr)

✅ **Checkpoint 7** : Tous les services sont configurés

---

## 🎬 Étape 8 : Premier Test de Téléchargement

### 8.1 Demander un Contenu

1. Ouvrir **Jellyseerr** : http://IP-VM:5055
2. **Rechercher** une série (ex: "Breaking Bad")
3. **Cliquer** sur "Request"
4. **Sélectionner** les saisons
5. **Confirmer**

### 8.2 Suivre la Progression

```bash
# Voir les logs en temps réel
docker compose logs -f sonarr

# Ou via les interfaces web:
# - Sonarr : Activity → Queue
# - qBittorrent : Downloads tab
```

### 8.3 Workflow Automatique

```
Jellyseerr → Sonarr
    ↓
Sonarr → Prowlarr (recherche)
    ↓
Prowlarr → qBittorrent (via VPN)
    ↓
Téléchargement complet
    ↓
Sonarr → Renomme et déplace vers /media/tv
    ↓
Bazarr → Télécharge sous-titres
    ↓
Jellyfin → Détecte automatiquement
```

### 8.4 Regarder dans Jellyfin

Une fois le téléchargement terminé :

1. Ouvrir **Jellyfin** : http://IP-VM:8096
2. La série apparaît automatiquement
3. **Lire** et profiter !

✅ **Checkpoint 8** : Premier téléchargement réussi !

---

## 📊 Commandes Utiles

### Gestion des Services

```bash
# Voir les logs de tous les services
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f jellyfin

# Redémarrer un service
docker compose restart sonarr

# Arrêter tous les services
docker compose down

# Démarrer tous les services
docker compose up -d

# Status
docker compose ps
```

### Avec Make (Plus Simple)

```bash
# Voir toutes les commandes
make help

# Status
make status

# Logs
make logs

# Health check
make health

# URLs
make urls

# Vérifier VPN
make check-vpn

# Mettre à jour
make update
```

### Maintenance

```bash
# Espace disque utilisé
df -h
du -sh /opt/homelab/*

# Ressources en temps réel
htop

# Nettoyer Docker
docker system prune -a
```

---

## ⚠️ Troubleshooting Rapide

### Problème : Service ne démarre pas

```bash
# Voir les logs du service
docker compose logs nom-du-service

# Redémarrer
docker compose restart nom-du-service
```

### Problème : VPN ne fonctionne pas

```bash
# Vérifier les credentials
cat .env | grep OPENVPN

# Voir logs Gluetun
docker compose logs gluetun

# Redémarrer le VPN
docker compose restart gluetun qbittorrent prowlarr
```

### Problème : Pas d'accès web

```bash
# Vérifier que le port est ouvert
sudo ufw status | grep 8096

# Vérifier l'IP de la VM
ip a

# Tester depuis la VM elle-même
curl http://localhost:8096
```

---

## ✅ Checklist Finale

- [ ] Système Debian 12 à jour
- [ ] Projet cloné depuis GitHub
- [ ] Installation exécutée sans erreur
- [ ] Docker et Docker Compose installés
- [ ] Tous les containers démarrés
- [ ] VPN vérifié (IPs différentes)
- [ ] Health check OK
- [ ] Tous les services accessibles en web
- [ ] Jellyfin configuré
- [ ] Prowlarr + indexeurs configurés
- [ ] Sonarr/Radarr configurés
- [ ] qBittorrent sécurisé
- [ ] Jellyseerr connecté
- [ ] Premier téléchargement testé

---

## 🎉 Félicitations !

Votre **HomeLab Media Server** est maintenant opérationnel ! 🚀

**Prochaines étapes :**
- Ajoutez plus d'indexeurs dans Prowlarr
- Configurez Bazarr pour les sous-titres
- Créez des utilisateurs dans Jellyfin
- Explorez les paramètres avancés

**Documentation complète** : [README.md](README.md)

**Besoin d'aide ?** : [docs/troubleshooting.md](docs/troubleshooting.md)

---

**Bon streaming ! 🎬**

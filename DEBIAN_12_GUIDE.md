# 🐧 Déploiement sur Debian 12

**Guide spécifique pour installer HomeLab Media Server sur Debian 12 "Bookworm"**

---

## ✅ Pourquoi Debian 12 est Excellent

### Avantages vs Ubuntu Server

| Critère | Debian 12 | Ubuntu Server 22.04 |
|---------|-----------|---------------------|
| **Stabilité** | ⭐⭐⭐⭐⭐ Excellente | ⭐⭐⭐⭐ Très bonne |
| **Légèreté** | ⭐⭐⭐⭐⭐ Minimal | ⭐⭐⭐⭐ Bon |
| **LTS** | 5 ans | 5 ans |
| **Paquets** | Très stables | Plus récents |
| **Communauté** | Énorme | Très grande |
| **Docker** | ✅ Natif | ✅ Natif |
| **RAM utilisée** | ~200-300 MB | ~300-400 MB |
| **Bloatware** | ❌ Aucun | ⚠️ Snap présent |

### 🎯 Recommandation

**Debian 12 est PARFAIT pour ce projet car :**

✅ **Plus stable** - Moins de mises à jour cassantes
✅ **Plus léger** - Économise RAM pour Docker
✅ **Sans snap** - Installation Docker plus propre
✅ **Minimaliste** - Exactement ce dont on a besoin
✅ **LTS 5 ans** - Support jusqu'à 2028
✅ **Compatible 100%** - Scripts fonctionnent identiquement

---

## 📥 Installation Debian 12

### 1. Télécharger l'ISO

```
URL: https://www.debian.org/download
Version: Debian 12.5 "Bookworm"
Type: netinst (recommandé, ~650 MB)
Architecture: amd64

Lien direct ISO netinst:
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso
```

### 2. Configuration VM

**Paramètres identiques Ubuntu :**

```
Nom:              HomeLab-Media-Debian
Type:             Linux
Version:          Debian (64-bit)
RAM:              8192 MB (8 GB)
CPU:              4 cœurs
Disque:           60 GB (système) + optionnel (média)
Réseau:           Pont (Bridge)
```

### 3. Installation Guidée

**Écran d'installation :**

```
Mode:                Install (pas Graphical Install)
Langue:              Français / French
Pays:                France / Other → Europe → France
Locales:             fr_FR.UTF-8
Clavier:             Français
Nom de machine:      homelab
Domaine:             [laisser vide]
Mot de passe root:   [définir un mot de passe fort]
Utilisateur:         votre-nom
Mot de passe user:   [définir un mot de passe fort]
```

**Partitionnement :**

```
Méthode:             Assisté - utiliser tout le disque
Schéma:              Tout dans une seule partition (recommandé)
```

**Miroir réseau :**

```
Pays:                France
Miroir:              deb.debian.org (par défaut)
Proxy:               [laisser vide si pas de proxy]
```

**Logiciels à installer :**

```
⚠️ IMPORTANT - Décocher tout sauf:

✅ Serveur SSH
❌ Environnement de bureau Debian
❌ ... GNOME
❌ ... Xfce
❌ ... KDE Plasma
❌ ... Cinnamon
❌ ... MATE
❌ ... LXDE
❌ ... LXQt
❌ Serveur web
❌ Serveur d'impression
✅ Utilitaires usuels du système
```

**GRUB :**

```
Installer GRUB:      Oui
Périphérique:        /dev/sda (disque principal)
```

---

## 🚀 Post-Installation Debian 12

### 1. Première Connexion

```bash
# Redémarrer la VM après installation
# Se connecter en SSH depuis votre PC
ssh votre-user@IP-DEBIAN
```

### 2. Configuration sudo (Important !)

Par défaut, votre utilisateur n'est pas dans `sudo` sur Debian :

```bash
# Se connecter en root
su -

# Installer sudo
apt update
apt install -y sudo

# Ajouter votre utilisateur au groupe sudo
usermod -aG sudo votre-user

# Vérifier
groups votre-user

# Quitter session root
exit

# Déconnecter et reconnecter pour que sudo fonctionne
exit
ssh votre-user@IP-DEBIAN
```

### 3. Mise à Jour Système

```bash
# Mettre à jour la liste des paquets
sudo apt update

# Mettre à jour le système
sudo apt upgrade -y

# Installer outils de base
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    net-tools \
    htop \
    ncdu \
    ca-certificates \
    gnupg \
    lsb-release
```

### 4. Configuration Réseau (IP Statique)

```bash
# Identifier votre interface réseau
ip a
# Exemple: ens18, ens33, eth0, enp0s3

# Éditer la configuration réseau
sudo nano /etc/network/interfaces
```

**Configuration IP statique :**

```bash
# Interface loopback
auto lo
iface lo inet loopback

# Interface réseau principale (adapter le nom)
auto ens18
iface ens18 inet static
    address 192.168.1.100      # Votre IP souhaitée
    netmask 255.255.255.0
    gateway 192.168.1.1        # Votre box/routeur
    dns-nameservers 8.8.8.8 8.8.4.4
```

**Appliquer :**

```bash
# Redémarrer le service réseau
sudo systemctl restart networking

# Ou redémarrer la VM
sudo reboot

# Vérifier
ip a
ping 8.8.8.8
```

---

## 🐳 Installation HomeLab Media Server sur Debian 12

### Méthode 1 : Installation Automatique (Recommandée)

```bash
# Cloner le projet
git clone https://github.com/BluuArtiis-FR/HomeMedia.git
cd HomeMedia

# Rendre les scripts exécutables
chmod +x install.sh generate-compose.sh health-check.sh

# Lancer l'installation automatique
sudo ./install.sh
```

**Le script va automatiquement :**
1. ✅ Détecter Debian 12
2. ✅ Installer Docker via les dépôts officiels Debian
3. ✅ Installer Docker Compose
4. ✅ Configurer UFW
5. ✅ Installer Fail2Ban
6. ✅ Tout configurer automatiquement

**Durée : 5-10 minutes**

---

### Méthode 2 : Installation Manuelle (Détaillée)

Si vous préférez comprendre chaque étape :

#### Étape 1 : Installer Docker

```bash
# 1. Ajouter la clé GPG officielle de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 2. Ajouter le repository Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Mettre à jour et installer Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Démarrer et activer Docker
sudo systemctl start docker
sudo systemctl enable docker

# 5. Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# 6. Appliquer les changements (déconnexion/reconnexion)
newgrp docker

# 7. Vérifier l'installation
docker --version
docker compose version
docker run hello-world
```

#### Étape 2 : Configurer le Pare-feu UFW

```bash
# Installer UFW
sudo apt install -y ufw

# Activer UFW
sudo ufw --force enable

# Configurer les règles par défaut
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Ouvrir les ports nécessaires
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 8096/tcp comment 'Jellyfin'
sudo ufw allow 5055/tcp comment 'Jellyseerr'
sudo ufw allow 8989/tcp comment 'Sonarr'
sudo ufw allow 7878/tcp comment 'Radarr'
sudo ufw allow 8080/tcp comment 'qBittorrent'
sudo ufw allow 9696/tcp comment 'Prowlarr'
sudo ufw allow 6767/tcp comment 'Bazarr'
sudo ufw allow 8686/tcp comment 'Lidarr'
sudo ufw allow 8787/tcp comment 'Readarr'

# Recharger
sudo ufw reload

# Vérifier
sudo ufw status verbose
```

#### Étape 3 : Installer Fail2Ban

```bash
# Installer
sudo apt install -y fail2ban

# Créer configuration locale
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Éditer la config
sudo nano /etc/fail2ban/jail.local
```

**Configuration recommandée :**

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 22
logpath = /var/log/auth.log
```

**Démarrer Fail2Ban :**

```bash
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
sudo systemctl status fail2ban
```

#### Étape 4 : Créer la Structure de Dossiers

```bash
# Créer les répertoires
sudo mkdir -p /opt/homelab/{config,data,downloads,media}
sudo mkdir -p /opt/homelab/media/{movies,tv,music,books}
sudo mkdir -p /opt/homelab/config/{jellyfin,sonarr,radarr,lidarr,readarr,qbittorrent,prowlarr,bazarr,jellyseerr}

# Définir les permissions
sudo chown -R $USER:$USER /opt/homelab
sudo chmod -R 755 /opt/homelab
```

#### Étape 5 : Configurer l'Environnement

```bash
# Aller dans le dossier du projet
cd ~/HomeMedia

# Copier le template .env
cp .env.example .env

# Éditer avec vos credentials ProtonVPN
nano .env
```

**Modifier ces lignes :**

```bash
OPENVPN_USER=votre-username-protonvpn
OPENVPN_PASSWORD=votre-password-protonvpn

# Optionnel : personnaliser les chemins
CONFIG_PATH=/opt/homelab/config
DATA_PATH=/opt/homelab/data
DOWNLOADS_PATH=/opt/homelab/downloads
MEDIA_PATH=/opt/homelab/media
```

#### Étape 6 : Déployer les Services

```bash
# Générer docker-compose.yml (ou utiliser celui par défaut)
# Option 1 : Utiliser le fichier par défaut
# Rien à faire, docker-compose.yml existe déjà

# Option 2 : Générer personnalisé
./generate-compose.sh

# Démarrer tous les services
docker compose up -d

# Vérifier
docker compose ps
```

---

## 🔍 Vérifications Post-Installation

```bash
# 1. Docker fonctionne
docker --version
docker compose version

# 2. Services démarrés
docker compose ps

# 3. VPN actif
docker exec gluetun wget -qO- https://api.ipify.org
# Comparer avec votre vraie IP (doit être différent)
curl https://api.ipify.org

# 4. Health check complet
./health-check.sh

# 5. Ressources
free -h
df -h
```

---

## 🎯 Accès aux Services

Depuis votre navigateur (remplacez `IP-DEBIAN` par l'IP de votre VM) :

```
✅ Jellyfin:     http://IP-DEBIAN:8096
✅ Jellyseerr:   http://IP-DEBIAN:5055
✅ Sonarr:       http://IP-DEBIAN:8989
✅ Radarr:       http://IP-DEBIAN:7878
✅ qBittorrent:  http://IP-DEBIAN:8080
✅ Prowlarr:     http://IP-DEBIAN:9696
✅ Bazarr:       http://IP-DEBIAN:6767
```

---

## 🔧 Optimisations Spécifiques Debian 12

### 1. Désactiver Services Inutiles

```bash
# Lister les services actifs
systemctl list-unit-files --state=enabled

# Désactiver services inutiles (exemples)
sudo systemctl disable bluetooth.service
sudo systemctl disable avahi-daemon.service
sudo systemctl disable ModemManager.service
```

### 2. Optimiser Systemd Journal

```bash
# Limiter la taille des logs
sudo nano /etc/systemd/journald.conf
```

**Ajouter :**

```ini
[Journal]
SystemMaxUse=200M
RuntimeMaxUse=100M
```

**Appliquer :**

```bash
sudo systemctl restart systemd-journald
```

### 3. Optimiser Swappiness (si RAM suffisante)

```bash
# Voir valeur actuelle
cat /proc/sys/vm/swappiness

# Réduire swappiness (défaut 60)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Appliquer
sudo sysctl -p
```

---

## 🆚 Comparaison Détaillée

### RAM Utilisée (VM au repos)

| Distribution | RAM Utilisée | Docker Containers | Total |
|--------------|--------------|-------------------|-------|
| **Debian 12** | ~250 MB | ~2 GB | ~2.25 GB |
| **Ubuntu Server** | ~350 MB | ~2 GB | ~2.35 GB |

**Économie : ~100 MB** → Plus de RAM pour Docker !

### Vitesse Boot

| Distribution | Boot Time |
|--------------|-----------|
| **Debian 12** | ~15-20 sec |
| **Ubuntu Server** | ~20-25 sec |

### Mises à Jour

| Distribution | Fréquence | Stabilité |
|--------------|-----------|-----------|
| **Debian 12** | Très rares (sécurité) | ⭐⭐⭐⭐⭐ |
| **Ubuntu Server** | Mensuelles | ⭐⭐⭐⭐ |

---

## ⚠️ Différences à Connaître

### 1. Pare-feu par Défaut

**Ubuntu :** UFW pré-installé (désactivé)
**Debian :** Aucun pare-feu (on installe UFW)

→ **Pas de problème** : Le script `install.sh` installe UFW automatiquement

### 2. Sudo

**Ubuntu :** Utilisateur ajouté automatiquement à sudo
**Debian :** Il faut l'ajouter manuellement (voir ci-dessus)

→ **Solution simple** : `su -` puis `usermod -aG sudo votre-user`

### 3. Paquets Non-free

**Debian :** Seuls les paquets 100% libres par défaut
**Ubuntu :** Paquets propriétaires disponibles

→ **Pas d'impact** : Docker et nos services sont tous libres

---

## 📋 Checklist Installation Debian 12

### Avant Installation
- [ ] ISO Debian 12 téléchargée
- [ ] VM créée (4 CPU, 8 GB RAM, 60 GB disque)
- [ ] Réseau configuré en mode pont

### Installation OS
- [ ] Debian 12 installé (mode texte)
- [ ] SSH activé pendant installation
- [ ] Utilisateur créé
- [ ] Système à jour (`apt update && apt upgrade`)

### Configuration Initiale
- [ ] Utilisateur ajouté au groupe sudo
- [ ] Outils de base installés
- [ ] IP statique configurée
- [ ] Connexion SSH fonctionnelle

### HomeLab Media Server
- [ ] Projet cloné
- [ ] `sudo ./install.sh` exécuté
- [ ] Credentials VPN entrés
- [ ] Services démarrés
- [ ] VPN vérifié
- [ ] Health check OK

### Configuration Services
- [ ] Jellyfin configuré
- [ ] Prowlarr + indexeurs
- [ ] Sonarr/Radarr configurés
- [ ] Jellyseerr connecté

---

## 🎯 Recommandation Finale

### Utiliser Debian 12 si :

✅ Vous cherchez la **stabilité maximale**
✅ Vous voulez le **minimum de RAM utilisée**
✅ Vous préférez **moins de mises à jour**
✅ Vous voulez **éviter Snap** (Ubuntu)
✅ Vous aimez le **minimalisme**

### Utiliser Ubuntu Server 22.04 si :

✅ Vous débutez avec Linux
✅ Vous voulez des **paquets plus récents**
✅ Vous préférez la **facilité** (sudo auto)
✅ Plus grande **communauté** (tutoriels)

---

## 💡 Mon Avis Personnel

**Pour ce projet spécifique, je recommande Debian 12 car :**

1. ⭐ **Plus stable** - Parfait pour serveur média 24/7
2. ⭐ **Plus léger** - Économise 100 MB de RAM
3. ⭐ **Moins de bloat** - Juste ce qu'il faut
4. ⭐ **Scripts compatibles 100%** - Fonctionne identiquement

**Seul "inconvénient" :** Ajouter manuellement sudo (30 secondes)

---

## 📞 Support Debian 12

Les scripts fonctionnent **exactement pareil** sur Debian 12.

**Si problème spécifique Debian :**
- Vérifiez que sudo est installé et configuré
- Vérifiez que `/etc/apt/sources.list` est correct
- Consultez : https://wiki.debian.org/

---

**✅ Debian 12 est parfait pour HomeLab Media Server !** 🐧🚀

**Installation identique à Ubuntu, stabilité supérieure !**

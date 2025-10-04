# 🖥️ Guide de Déploiement sur VM

**Guide complet pour déployer HomeLab Media Server sur une machine virtuelle**

---

## 📋 Prérequis VM

### 💻 Configuration Minimale (Fonctionnel)

| Ressource | Minimum | Recommandé | Optimal |
|-----------|---------|------------|---------|
| **CPU** | 2 cœurs | 4 cœurs | 6-8 cœurs |
| **RAM** | 4 GB | 8 GB | 16 GB |
| **Stockage Système** | 20 GB | 40 GB | 60 GB (SSD) |
| **Stockage Média** | 100 GB | 500 GB | 1-4 TB (HDD) |
| **Réseau** | 100 Mbps | 1 Gbps | 1 Gbps |

### 🎯 Recommandation par Usage

#### Usage Léger (1-2 utilisateurs, 720p-1080p)
```
CPU:      2-4 cœurs
RAM:      8 GB
Système:  40 GB SSD
Média:    500 GB HDD
```

#### Usage Moyen (3-5 utilisateurs, 1080p)
```
CPU:      4-6 cœurs
RAM:      12 GB
Système:  60 GB SSD
Média:    1-2 TB HDD
```

#### Usage Intensif (5-10 utilisateurs, 1080p multi-stream)
```
CPU:      8+ cœurs
RAM:      16-32 GB
Système:  100 GB SSD
Média:    2-4 TB HDD
```

---

## 🖥️ Configuration VM

### Option 1 : VirtualBox

#### Création VM

```bash
# Spécifications recommandées
Nom:              HomeLab-Media-Server
Type:             Linux
Version:          Ubuntu (64-bit)
RAM:              8192 MB (8 GB)
Disque:           60 GB (dynamique)
CPU:              4 cœurs
Accélération 3D:  Désactivé (pas de GPU)
```

#### Configuration Réseau

**Mode 1 : Pont (Bridge)** - Recommandé
```
Adaptateur 1:     Réseau Pont
Type:             Carte Intel PRO/1000 MT Desktop
Mode promiscuité: Tout autoriser
```

**Avantages :**
- ✅ IP directe sur réseau local
- ✅ Accessible depuis tous les appareils
- ✅ Pas de redirection de ports

**Mode 2 : NAT avec redirection** - Alternative
```
Adaptateur 1:     NAT
Redirections de ports:
  - Jellyfin:    8096 → 8096
  - Jellyseerr:  5055 → 5055
  - Sonarr:      8989 → 8989
  - Radarr:      7878 → 7878
  - qBittorrent: 8080 → 8080
  - Prowlarr:    9696 → 9696
  - Bazarr:      6767 → 6767
```

#### Dossiers Partagés (Optionnel)

```bash
# Pour partager un dossier média existant
VirtualBox → Paramètres → Dossiers partagés
Nom:              media
Chemin hôte:      D:\Media (ou votre chemin)
Auto-montage:     ✅
Permanent:        ✅
```

### Option 2 : VMware Workstation/Player

```
Nom:              HomeLab-Media-Server
OS:               Linux / Ubuntu 22.04 64-bit
RAM:              8 GB
CPU:              4 cœurs
Disque:           60 GB (Thin provisioned)
Réseau:           Bridged (Autodetect)
```

### Option 3 : Proxmox VE

```yaml
VM ID:            100
Nom:              homelab-media
OS:               Ubuntu 22.04
CPU:              4 cores (host)
RAM:              8192 MB
Disque système:   60 GB (local-lvm)
Disque média:     500 GB+ (stockage séparé)
Réseau:           vmbr0 (bridge)
Boot:             SCSI / VirtIO
```

### Option 4 : Hyper-V (Windows)

```
Nom:              HomeLab-Media-Server
Génération:       2
RAM:              8192 MB (dynamique 4-16 GB)
CPU:              4 processeurs virtuels
Disque:           60 GB (dynamique)
Commutateur:      Commutateur externe
```

---

## 🐧 Installation OS

### Ubuntu Server 22.04 LTS (Recommandé)

#### 1. Télécharger l'ISO

```
URL: https://ubuntu.com/download/server
Version: Ubuntu Server 22.04.3 LTS
Fichier: ubuntu-22.04.3-live-server-amd64.iso
Taille: ~2 GB
```

#### 2. Installation Guidée

```bash
# Paramètres installation
Langue:           Français (ou English)
Clavier:          French
Type:             Ubuntu Server (minimal)
Réseau:           DHCP (ou IP statique)
Disque:           Utiliser tout le disque
Profil:
  - Nom:          votre-nom
  - Serveur:      homelab
  - Utilisateur:  votre-user
  - Mot de passe: [sécurisé]
SSH:              ✅ Installer OpenSSH
Snaps:            ❌ Aucun (on installera manuellement)
```

#### 3. Première Connexion

```bash
# Se connecter en SSH depuis votre PC
ssh votre-user@IP-DE-LA-VM

# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer les outils de base
sudo apt install -y curl wget git vim net-tools
```

---

## 🚀 Déploiement HomeLab Media Server

### Étape 1 : Récupérer le Projet

```bash
# Cloner le repository
git clone https://github.com/BluuArtiis-FR/HomeMedia.git
cd HomeMedia

# Rendre les scripts exécutables
chmod +x install.sh generate-compose.sh health-check.sh
```

### Étape 2 : Installation Automatique

```bash
# Lancer l'installation (5-10 minutes)
sudo ./install.sh
```

**Le script va :**
1. ✅ Vérifier prérequis (RAM, CPU, disque)
2. ✅ Installer Docker + Docker Compose
3. ✅ Configurer pare-feu UFW
4. ✅ Installer Fail2Ban
5. ✅ Créer structure `/opt/homelab/`
6. ✅ Demander vos credentials ProtonVPN
7. ✅ Générer `docker-compose.yml`
8. ✅ Démarrer tous les services
9. ✅ Afficher les URLs d'accès

### Étape 3 : Vérification

```bash
# Vérifier que Docker fonctionne
docker --version
docker compose version

# Vérifier les containers
docker compose ps

# Health check complet
./health-check.sh

# Vérifier VPN
make check-vpn
```

---

## 🌐 Configuration Réseau VM

### Option A : IP Statique (Recommandé)

```bash
# Éditer la configuration réseau
sudo nano /etc/netplan/00-installer-config.yaml
```

**Configuration :**

```yaml
network:
  version: 2
  ethernets:
    ens33:  # Adaptez selon votre interface (ip a pour voir)
      dhcp4: no
      addresses:
        - 192.168.1.100/24  # Votre IP souhaitée
      routes:
        - to: default
          via: 192.168.1.1  # Votre passerelle (box)
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

**Appliquer :**

```bash
sudo netplan apply

# Vérifier
ip a
ping 8.8.8.8
```

### Option B : Réservation DHCP (Plus Simple)

```
1. Se connecter à votre box/routeur
2. Aller dans DHCP → Réservations
3. Ajouter réservation avec MAC de la VM
4. Redémarrer la VM
```

---

## 📂 Configuration Stockage

### Scénario 1 : Tout sur le Disque VM

```bash
# Structure par défaut (créée par install.sh)
/opt/homelab/
  ├── config/       # Configurations services (~2 GB)
  ├── data/         # Données applicatives (~1 GB)
  ├── downloads/    # Téléchargements en cours (~50-100 GB)
  └── media/        # Bibliothèque finale (500 GB+)
      ├── movies/
      ├── tv/
      ├── music/
      └── books/
```

**Prérequis :** Disque VM de 600 GB minimum

### Scénario 2 : Stockage Externe/NAS (Recommandé)

#### Monter un Partage SMB/CIFS

```bash
# Installer cifs-utils
sudo apt install -y cifs-utils

# Créer point de montage
sudo mkdir -p /mnt/nas/media

# Créer fichier credentials
sudo nano /root/.nascredentials
```

**Contenu `.nascredentials` :**
```
username=votre-user-nas
password=votre-password-nas
```

**Protéger :**
```bash
sudo chmod 600 /root/.nascredentials
```

**Montage automatique :**
```bash
sudo nano /etc/fstab
```

**Ajouter :**
```
//IP-NAS/partage /mnt/nas/media cifs credentials=/root/.nascredentials,uid=1000,gid=1000 0 0
```

**Monter :**
```bash
sudo mount -a

# Vérifier
ls -la /mnt/nas/media
```

**Modifier .env :**
```bash
nano .env

# Changer
MEDIA_PATH=/mnt/nas/media
DOWNLOADS_PATH=/mnt/nas/downloads
```

#### Monter un Disque Additionnel

```bash
# Lister les disques
lsblk

# Formater (ATTENTION: détruit les données!)
sudo mkfs.ext4 /dev/sdb1

# Créer point de montage
sudo mkdir -p /opt/homelab/media

# Monter
sudo mount /dev/sdb1 /opt/homelab/media

# Montage auto au démarrage
echo '/dev/sdb1 /opt/homelab/media ext4 defaults 0 2' | sudo tee -a /etc/fstab

# Permissions
sudo chown -R $USER:$USER /opt/homelab/media
```

---

## ⚡ Optimisations VM

### 1. Désactiver le Swap (si RAM suffisante)

```bash
# Vérifier swap
free -h

# Désactiver
sudo swapoff -a

# Permanent
sudo nano /etc/fstab
# Commenter la ligne swap avec #
```

### 2. Activer Nested Virtualization (si hyperviseur)

**VirtualBox :**
```bash
VBoxManage modifyvm "HomeLab-Media-Server" --nested-hw-virt on
```

**VMware :**
```
Settings → Processors → Virtualize Intel VT-x/EPT → ✅
```

### 3. Optimiser I/O Disque

**VirtualBox :**
```
Settings → Storage → Controller: SATA
  - Type: AHCI
  - Use Host I/O Cache: ✅
```

### 4. CPU Pinning (Proxmox)

```bash
# Dans la config VM
qm set 100 -cpu host
```

---

## 🔐 Sécurité VM

### 1. Firewall UFW (Installé automatiquement)

```bash
# Vérifier status
sudo ufw status verbose

# Ports ouverts par install.sh:
# - 22 (SSH)
# - 8096 (Jellyfin)
# - 5055 (Jellyseerr)
# - 8989 (Sonarr)
# - 7878 (Radarr)
# - 8080 (qBittorrent)
# - 9696 (Prowlarr)
# - 6767 (Bazarr)
```

### 2. Fail2Ban (Installé automatiquement)

```bash
# Vérifier status
sudo fail2ban-client status

# Voir bans SSH
sudo fail2ban-client status sshd
```

### 3. Changer Port SSH (Optionnel)

```bash
sudo nano /etc/ssh/sshd_config

# Modifier
Port 2222  # Au lieu de 22

# Redémarrer
sudo systemctl restart sshd

# Ouvrir nouveau port
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
```

---

## 📊 Monitoring VM

### Ressources Temps Réel

```bash
# CPU/RAM
htop

# Disque
df -h
du -sh /opt/homelab/*

# Réseau
iftop

# Docker
docker stats
```

### Logs

```bash
# Logs système
sudo journalctl -xe

# Logs Docker
docker compose logs -f

# Logs service spécifique
docker compose logs -f jellyfin
```

---

## 🔄 Sauvegardes VM

### 1. Snapshot VM (Avant grosse modif)

**VirtualBox :**
```
Machine → Take Snapshot
Nom: avant-mise-a-jour-[date]
```

**Proxmox :**
```bash
qm snapshot 100 avant-modif
```

### 2. Sauvegarde Configs

```bash
# Créer backup
make backup

# Ou manuellement
tar -czf backup-$(date +%F).tar.gz /opt/homelab/config
```

### 3. Export VM Complète

**VirtualBox :**
```
File → Export Appliance → Format OVA
```

---

## 🧪 Tests Post-Déploiement

### Checklist Validation

```bash
# 1. Docker fonctionne
docker --version

# 2. Services démarrés
docker compose ps

# 3. VPN actif
docker exec gluetun wget -qO- https://api.ipify.org

# 4. Accès web (depuis PC)
curl http://IP-VM:8096  # Jellyfin
curl http://IP-VM:5055  # Jellyseerr

# 5. Health check
./health-check.sh

# 6. Ressources
free -h
df -h
```

### URLs à Tester

Remplacez `IP-VM` par l'IP de votre VM :

```
✅ http://IP-VM:8096  - Jellyfin
✅ http://IP-VM:5055  - Jellyseerr
✅ http://IP-VM:8989  - Sonarr
✅ http://IP-VM:7878  - Radarr
✅ http://IP-VM:8080  - qBittorrent
✅ http://IP-VM:9696  - Prowlarr
✅ http://IP-VM:6767  - Bazarr
```

---

## ⚠️ Problèmes Courants VM

### 1. VM lente / ralentissements

**Causes :**
- ❌ RAM insuffisante
- ❌ Swap trop utilisé
- ❌ Disque plein
- ❌ CPU surchargé

**Solutions :**
```bash
# Vérifier ressources
free -h
df -h
top

# Augmenter RAM VM
# Ajouter CPU
# Nettoyer espace disque
docker system prune -a
```

### 2. Réseau inaccessible

**Solution :**
```bash
# Vérifier IP
ip a

# Redémarrer réseau
sudo systemctl restart NetworkManager

# Tester ping
ping 8.8.8.8
ping IP-BOX
```

### 3. VPN ne fonctionne pas

**Solution :**
```bash
# Vérifier credentials
cat .env | grep OPENVPN

# Voir logs Gluetun
docker compose logs gluetun

# Redémarrer VPN
docker compose restart gluetun qbittorrent prowlarr
```

---

## 📈 Estimation Ressources par Usage

### Scénario 1 : Solo (1 utilisateur)

```
CPU:       2 cœurs → 30-50% utilisation
RAM:       4-6 GB utilisés
Disque:
  - Système: 10 GB
  - Downloads: 50 GB
  - Media: 200+ GB
Réseau:    10-50 Mbps (streaming 1080p)
```

### Scénario 2 : Familial (3-5 utilisateurs)

```
CPU:       4 cœurs → 40-70% utilisation
RAM:       8-12 GB utilisés
Disque:
  - Système: 15 GB
  - Downloads: 100 GB
  - Media: 1+ TB
Réseau:    50-150 Mbps (multi-stream)
```

### Scénario 3 : Intensif (5-10 utilisateurs)

```
CPU:       6-8 cœurs → 60-90% utilisation
RAM:       12-16 GB utilisés
Disque:
  - Système: 20 GB
  - Downloads: 200 GB
  - Media: 2-4 TB
Réseau:    100-300 Mbps
```

---

## 🎯 Checklist Déploiement VM

### Avant Installation

- [ ] VM créée avec ressources suffisantes
- [ ] Ubuntu Server 22.04 installé
- [ ] Réseau configuré (pont ou NAT)
- [ ] IP statique ou réservation DHCP
- [ ] SSH fonctionnel
- [ ] Compte ProtonVPN prêt

### Installation

- [ ] Projet cloné
- [ ] `sudo ./install.sh` exécuté
- [ ] Credentials VPN entrés
- [ ] Installation terminée sans erreur
- [ ] Services démarrés

### Post-Installation

- [ ] Health check OK (`./health-check.sh`)
- [ ] VPN vérifié (IP différente)
- [ ] Tous les ports accessibles
- [ ] Stockage configuré
- [ ] Sauvegarde config créée

### Configuration Services

- [ ] Jellyfin configuré
- [ ] Prowlarr + indexeurs
- [ ] Sonarr configuré
- [ ] Radarr configuré
- [ ] qBittorrent sécurisé
- [ ] Jellyseerr connecté

---

## 📞 Support

Si problèmes :

1. **Vérifier logs** : `docker compose logs -f`
2. **Health check** : `./health-check.sh`
3. **Documentation** : [docs/troubleshooting.md](docs/troubleshooting.md)
4. **GitHub Issues** : https://github.com/BluuArtiis-FR/HomeMedia/issues

---

**✅ Votre VM est maintenant prête pour HomeLab Media Server !** 🚀

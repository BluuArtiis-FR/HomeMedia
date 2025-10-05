# 🚀 Marche à suivre - Réinstallation VM

## ⚡ Version rapide (5 minutes de lecture)

---

## 📌 Ce qui a été corrigé

✅ **Support des bibliothèques anime** (Films, Séries, Anime)
✅ **Correction de l'erreur Prowlarr → Radarr/Sonarr** (documentation des noms de services Docker)
✅ **Suppression de l'avertissement Docker Compose**
✅ **Optimisation des volumes Bazarr**
✅ **Documentation complète de réinstallation**

---

## 🎯 Objectif

Repartir de zéro avec une installation **100% fonctionnelle** incluant :
- 📂 Bibliothèques Jellyfin : **Films**, **Séries**, **Anime**
- 🔗 Connexion **Prowlarr → Radarr/Sonarr** fonctionnelle
- 🔒 **VPN** opérationnel
- ⬇️ **qBittorrent** configuré

---

## 📝 Étapes à suivre

### 🔴 PHASE 1 : Nettoyage complet (10 minutes)

```bash
# 1. Se placer dans le répertoire du projet
cd /home/flo/HomeMedia

# 2. Arrêter et supprimer tous les containers Docker
docker compose down
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null
docker system prune -a --volumes -f

# 3. Arrêter les services locaux (hors Docker)
sudo systemctl stop jellyfin sonarr radarr prowlarr jellyseerr qbittorrent-nox 2>/dev/null
sudo systemctl disable jellyfin sonarr radarr prowlarr jellyseerr qbittorrent-nox 2>/dev/null

# 4. Supprimer tous les fichiers
rm -rf /home/flo/HomeMedia
sudo rm -rf /opt/homelab

# 5. Vérifier qu'aucun port n'est utilisé
sudo netstat -tulpn | grep -E '8096|8989|7878|9696'
# Si des processus apparaissent, les arrêter avec : sudo kill -9 PID
```

---

### 🟢 PHASE 2 : Réinstallation (15 minutes)

```bash
# 1. Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# 2. Cloner le projet mis à jour
cd ~
git clone https://github.com/BluuArtiis-FR/HomeMedia.git
cd HomeMedia

# 3. Configurer le fichier .env
cp .env.example .env
nano .env
```

**Configuration .env minimale :**
```bash
# VPN ProtonVPN
OPENVPN_USER=votre_username_protonvpn
OPENVPN_PASSWORD=votre_password_protonvpn

# Chemins
INSTALL_DIR=/opt/homelab

# Ports (par défaut)
JELLYFIN_PORT=8096
SONARR_PORT=8989
RADARR_PORT=7878
PROWLARR_PORT=9696
BAZARR_PORT=6767
JELLYSEERR_PORT=5055
QBITTORRENT_PORT=8080

# Timezone
TZ=Europe/Paris

# PUID/PGID (obtenir avec : id)
PUID=1000
PGID=1000
```

```bash
# 4. Lancer l'installation
chmod +x install.sh
sudo ./install.sh

# 5. Vérifier que tout est démarré
docker compose ps
```

**✅ Tous les containers doivent être "Up"**

---

### 🔵 PHASE 3 : Configuration (20 minutes)

#### 1️⃣ Jellyfin (http://VOTRE_IP:8096)
- Créer compte admin
- Ajouter bibliothèque **Films** → `/movies`
- Ajouter bibliothèque **Séries** → `/tv`
- Ajouter bibliothèque **Anime** → `/anime`

#### 2️⃣ qBittorrent (http://VOTRE_IP:8080)
- Login : `admin` / `adminadmin`
- **Changer le mot de passe** immédiatement
- Configurer : Outils → Options → Téléchargements → Chemin : `/downloads`

#### 3️⃣ Prowlarr (http://VOTRE_IP:9696)
- Activer l'authentification (Settings → General → Security)
- Ajouter des indexers (Indexers → Add Indexer)

#### 4️⃣ Radarr (http://VOTRE_IP:7878)
- Root Folder : `/movies`
- Download Client → qBittorrent :
  - Host : `qbittorrent` ← **NOM DU SERVICE**
  - Port : `8080`
  - Username : `admin`
  - Password : votre mot de passe qBittorrent

#### 5️⃣ Sonarr (http://VOTRE_IP:8989)
- Root Folder 1 : `/tv` (Séries)
- Root Folder 2 : `/anime` (Anime)
- Download Client → qBittorrent :
  - Host : `qbittorrent` ← **NOM DU SERVICE**
  - Port : `8080`
  - Username : `admin`
  - Password : votre mot de passe qBittorrent

#### 6️⃣ Prowlarr → Radarr/Sonarr (IMPORTANT !)

**Connecter Radarr :**
- Prowlarr → Settings → Apps → Add Application → Radarr
- Prowlarr Server : `http://localhost:9696`
- **Radarr Server : `http://radarr:7878`** ← **PAS LOCALHOST !**
- API Key : copier depuis Radarr → Settings → General → API Key
- Test → Save

**Connecter Sonarr :**
- Prowlarr → Settings → Apps → Add Application → Sonarr
- Prowlarr Server : `http://localhost:9696`
- **Sonarr Server : `http://sonarr:8989`** ← **PAS LOCALHOST !**
- API Key : copier depuis Sonarr → Settings → General → API Key
- Test → Save

**🔍 Vérification :** Les indexers ajoutés dans Prowlarr doivent maintenant apparaître dans Radarr et Sonarr !

#### 7️⃣ Bazarr (http://VOTRE_IP:6767)
- Settings → Sonarr :
  - Address : `http://sonarr:8989`
  - API Key : clé API Sonarr
- Settings → Radarr :
  - Address : `http://radarr:7878`
  - API Key : clé API Radarr
- Ajouter langue : Français
- Ajouter providers : OpenSubtitles, Subscene

#### 8️⃣ Jellyseerr (http://VOTRE_IP:5055)
- Connecter avec Jellyfin : `http://jellyfin:8096`
- Ajouter Radarr : `http://radarr:7878`
- Ajouter Sonarr : `http://sonarr:8989`

---

## 🎯 Règle d'or à retenir

| Contexte | URL à utiliser | Exemple |
|----------|----------------|---------|
| **Navigateur → Service** | `http://IP_VM:PORT` | `http://192.168.1.100:7878` |
| **Service → Service** | `http://nom_service:port_interne` | `http://radarr:7878` |

**❌ ERREUR FRÉQUENTE :** `http://localhost:7879`
**✅ CORRECT :** `http://radarr:7878`

---

## ✅ Checklist finale

- [ ] Tous les containers démarrés (`docker compose ps`)
- [ ] VPN fonctionne (IPs différentes : `docker exec gluetun wget -qO- ifconfig.me`)
- [ ] Jellyfin accessible avec 3 bibliothèques (Films, Séries, Anime)
- [ ] qBittorrent accessible et mot de passe changé
- [ ] Prowlarr connecté à Radarr (Test OK)
- [ ] Prowlarr connecté à Sonarr (Test OK)
- [ ] Indexers visibles dans Radarr
- [ ] Indexers visibles dans Sonarr
- [ ] Bazarr connecté à Radarr et Sonarr
- [ ] Jellyseerr fonctionnel

---

## 🐛 Problèmes fréquents

### ❌ "Name does not resolve" dans Prowlarr
**Solution :** Utiliser `http://radarr:7878` et non `http://localhost:7878`

### ❌ qBittorrent "Unauthorized"
**Solution :**
```bash
docker compose stop qbittorrent
sudo rm -rf /opt/homelab/config/qbittorrent/*
docker compose start qbittorrent
# Login : admin / adminadmin
```

### ❌ Container qui ne démarre pas
**Solution :**
```bash
docker compose logs nom_du_service
# Vérifier les erreurs dans les logs
```

### ❌ Port déjà utilisé
**Solution :**
```bash
# Identifier le processus
sudo netstat -tulpn | grep :8096
# Arrêter le service local
sudo systemctl stop jellyfin
```

---

## 📚 Documentation complète

Pour plus de détails, consulter :
- **Installation complète** : `VM_REINSTALL_COMPLETE.md`
- **Corrections apportées** : `CORRECTIONS_PROJET.md`
- **Validation du projet** : `VALIDATION_REPORT.md`

---

## 🎉 C'est parti !

Une fois toutes les étapes complétées, votre serveur média est **100% opérationnel** avec :
- 🎬 Gestion automatique des Films (Radarr)
- 📺 Gestion automatique des Séries (Sonarr)
- 🎌 Gestion automatique des Anime (Sonarr)
- 📝 Sous-titres automatiques (Bazarr)
- 🔍 Indexeurs synchronisés (Prowlarr)
- 🔒 VPN intégré (Gluetun)
- 📱 Requêtes utilisateurs (Jellyseerr)

**Bon streaming ! 🍿**

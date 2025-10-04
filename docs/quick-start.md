# 🚀 Guide de Démarrage Rapide

Ce guide vous permettra de déployer votre HomeLab Media Server en **moins de 15 minutes**.

## ⏱️ Installation Express (5 minutes)

### Prérequis
- Ubuntu/Debian 20.04+ (ou système compatible)
- 4 GB RAM minimum (8 GB recommandé)
- 50 GB d'espace disque libre
- Compte ProtonVPN actif

### Étapes d'Installation

```bash
# 1. Cloner le repository
git clone https://github.com/BluuArtiis-FR/homelab-media-server.git
cd homelab-media-server

# 2. Rendre les scripts exécutables
chmod +x install.sh generate-compose.sh health-check.sh

# 3. Lancer l'installation automatique
sudo ./install.sh
```

L'installateur va vous demander :
- ✅ Vos identifiants ProtonVPN
- ✅ Confirmation pour installer Docker, UFW, Fail2Ban
- ✅ Validation de la configuration

**C'est tout !** 🎉

---

## 📋 Première Configuration (10 minutes)

### 1. Jellyfin - Serveur Média (2 min)

Accédez à **http://VOTRE-IP:8096**

**Assistant de configuration :**

1. **Langue** : Sélectionnez "Français"
2. **Compte admin** :
   - Nom d'utilisateur : `admin`
   - Mot de passe : `[votre mot de passe sécurisé]`
3. **Bibliothèques médias** :
   - Films : `/media/movies`
   - Séries TV : `/media/tv`
   - Musique : `/media/music`
4. **Métadonnées** : Laissez les paramètres par défaut
5. **Finaliser** : Cliquez sur "Terminer"

✅ Jellyfin est configuré !

---

### 2. Prowlarr - Indexeurs (3 min)

Accédez à **http://VOTRE-IP:9696**

**Configuration :**

1. **Authentification** (Recommandé) :
   - Paramètres → Général → Sécurité
   - Méthode : "Formulaires (nom d'utilisateur/mot de passe)"
   - Nom d'utilisateur : `admin`
   - Mot de passe : `[votre mot de passe]`

2. **Ajouter des indexeurs** :
   - Indexeurs → Ajouter un indexeur
   - Recherchez "YGGTorrent", "RARBG", "The Pirate Bay"
   - Configurez vos credentials si nécessaire
   - **Important** : Activez FlareSolverr pour les sites Cloudflare
     - Tags → Ajouter "flaresolverr"
     - URL : `http://flaresolverr:8191`

3. **Tester** : Cliquez sur "Test" pour chaque indexeur

✅ Prowlarr configuré !

---

### 3. Sonarr - Gestion Séries (2 min)

Accédez à **http://VOTRE-IP:8989**

**Configuration rapide :**

1. **Lier Prowlarr** :
   - Paramètres → Indexeurs
   - Les indexeurs de Prowlarr apparaissent automatiquement
   - Sinon : Ajouter → Prowlarr
     - URL : `http://prowlarr:9696`
     - Clé API : Copiée depuis Prowlarr (Paramètres → Général)

2. **Ajouter qBittorrent** :
   - Paramètres → Clients de téléchargement → Ajouter → qBittorrent
   - Hôte : `gluetun`
   - Port : `8080`
   - Nom d'utilisateur : `admin`
   - Mot de passe : `adminadmin` (à changer dans qBittorrent)
   - Catégorie : `tv-sonarr`

3. **Profil de qualité** :
   - Paramètres → Profils
   - Sélectionnez "HD-1080p" par défaut

✅ Sonarr configuré !

---

### 4. Radarr - Gestion Films (2 min)

Accédez à **http://VOTRE-IP:7878**

**Configuration identique à Sonarr :**

1. Lier Prowlarr (même procédure)
2. Ajouter qBittorrent :
   - Hôte : `gluetun`
   - Port : `8080`
   - Catégorie : `movies-radarr`
3. Profil qualité : "HD-1080p"

✅ Radarr configuré !

---

### 5. qBittorrent - Client Torrent (1 min)

Accédez à **http://VOTRE-IP:8080**

**Login initial :**
- Nom d'utilisateur : `admin`
- Mot de passe : `adminadmin`

**Configuration :**

1. **Changer le mot de passe** :
   - Outils → Options → Web UI
   - Nouveau mot de passe : `[votre mot de passe sécurisé]`

2. **Vérifier le VPN** :
   - Outils → Options → Avancé
   - Interface réseau : Sélectionnez `tun0` (interface VPN)

3. **Vérifier l'IP** :
   - Ouvrez https://ipleak.net dans qBittorrent
   - Vérifiez que l'IP affichée est celle de ProtonVPN (pas votre vraie IP)

✅ qBittorrent sécurisé avec VPN !

---

### 6. Jellyseerr - Interface de Requêtes (2 min)

Accédez à **http://VOTRE-IP:5055**

**Assistant de configuration :**

1. **Connexion Jellyfin** :
   - URL Jellyfin : `http://jellyfin:8096`
   - Email : Votre email Jellyfin
   - Mot de passe : Votre mot de passe Jellyfin
   - Se connecter

2. **Synchronisation** :
   - Jellyseerr détecte automatiquement vos bibliothèques
   - Validez

3. **Ajouter Sonarr** :
   - Services → Sonarr → Ajouter
   - Serveur : `http://sonarr:8989`
   - Clé API : Copiée depuis Sonarr
   - Profil qualité : HD-1080p
   - Dossier racine : `/tv`

4. **Ajouter Radarr** :
   - Services → Radarr → Ajouter
   - Serveur : `http://radarr:7878`
   - Clé API : Copiée depuis Radarr
   - Profil qualité : HD-1080p
   - Dossier racine : `/movies`

✅ Jellyseerr opérationnel !

---

## 🎬 Premier Téléchargement

### Tester le Système

1. **Dans Jellyseerr** (http://VOTRE-IP:5055) :
   - Recherchez une série (ex: "Breaking Bad")
   - Cliquez sur "Demander"
   - Sélectionnez les saisons
   - Validez

2. **Vérification automatique** :
   - ✅ Jellyseerr → Sonarr
   - ✅ Sonarr → Prowlarr (recherche)
   - ✅ Prowlarr → qBittorrent (téléchargement via VPN)
   - ✅ qBittorrent → Téléchargement
   - ✅ Sonarr → Renommage et déplacement vers `/media/tv`
   - ✅ Bazarr → Téléchargement sous-titres
   - ✅ Jellyfin → Détection automatique

3. **Suivre la progression** :
   - Sonarr : Activité → File d'attente
   - qBittorrent : Onglet "Téléchargements"

4. **Regarder dans Jellyfin** :
   - Une fois terminé, ouvrez Jellyfin
   - La série apparaît automatiquement

---

## 🔒 Vérification Sécurité

### Test VPN Obligatoire

```bash
# Vérifier que qBittorrent utilise bien le VPN
docker exec gluetun wget -qO- https://api.ipify.org

# Comparer avec votre IP réelle (doit être différent)
curl https://api.ipify.org
```

**Les deux IPs DOIVENT être différentes !**

---

## 🏥 Vérification Santé Système

```bash
# Lancer le health check
./health-check.sh
```

Le script vérifie :
- ✅ État de tous les containers
- ✅ Ressources système (CPU/RAM/Disque)
- ✅ Connectivité VPN
- ✅ Ports ouverts
- ✅ Erreurs récentes dans les logs

---

## 📊 Tableau de Bord Récapitulatif

| Service | URL | Login par défaut | Description |
|---------|-----|------------------|-------------|
| **Jellyfin** | http://IP:8096 | admin / [configuré] | Streaming média |
| **Jellyseerr** | http://IP:5055 | [compte Jellyfin] | Requêtes utilisateurs |
| **Sonarr** | http://IP:8989 | Aucun* | Gestion séries |
| **Radarr** | http://IP:7878 | Aucun* | Gestion films |
| **qBittorrent** | http://IP:8080 | admin / adminadmin | Téléchargement |
| **Prowlarr** | http://IP:9696 | Aucun* | Indexeurs |
| **Bazarr** | http://IP:6767 | Aucun* | Sous-titres |

\* *Configurez l'authentification dans les paramètres*

---

## 🛠️ Commandes Utiles

```bash
# Voir tous les logs
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f jellyfin

# Redémarrer un service
docker compose restart sonarr

# Arrêter tous les services
docker compose down

# Démarrer tous les services
docker compose up -d

# Vérifier l'état
docker compose ps

# Health check complet
./health-check.sh

# Mise à jour des images
docker compose pull
docker compose up -d
```

---

## ❓ Problèmes Courants

### qBittorrent refuse les connexions

```bash
# Redémarrer Gluetun et qBittorrent
docker compose restart gluetun qbittorrent
```

### Prowlarr ne trouve pas d'indexeurs

- Vérifiez que FlareSolverr est actif : `docker compose ps flaresolverr`
- Ajoutez le tag `flaresolverr` aux indexeurs protégés par Cloudflare

### Jellyfin ne détecte pas les médias

```bash
# Forcer un scan
docker exec jellyfin curl -X POST "http://localhost:8096/Library/Refresh"
```

### Vérifier l'IP du VPN

```bash
# IP du VPN
docker exec gluetun wget -qO- https://ipinfo.io/ip

# Votre vraie IP (doit être différente!)
curl https://ipinfo.io/ip
```

---

## 🎉 Prochaines Étapes

Votre serveur est maintenant opérationnel ! Vous pouvez :

1. **Ajouter plus d'indexeurs** dans Prowlarr
2. **Configurer Bazarr** pour les sous-titres automatiques
3. **Créer des utilisateurs** dans Jellyfin pour votre famille
4. **Configurer Lidarr/Readarr** si vous voulez musique/livres
5. **Mettre en place un reverse proxy** (Traefik/Nginx) pour HTTPS

📖 Consultez la [documentation complète](configuration.md) pour aller plus loin !

---

**Félicitations ! Votre HomeLab Media Server est prêt à l'emploi !** 🚀

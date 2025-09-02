# ⚙️ Guide de Configuration

## Configuration Initiale

### 1. Variables d'Environnement

Modifiez le fichier `.env` :

```bash
# VPN Configuration
VPN_SERVICE_PROVIDER=protonvpn
VPN_TYPE=openvpn
OPENVPN_USER=votre-username
OPENVPN_PASSWORD=votre-password

# Timezone
TZ=Europe/Paris

# User/Group IDs
PUID=1000
PGID=1000

# Domaine (optionnel)
DOMAIN=votre-domaine.com
```

### 2. Jellyfin (Serveur Média)

#### Premier Démarrage
1. Accédez à http://votre-ip:8096
2. Suivez l'assistant de configuration
3. Créez un compte administrateur
4. Configurez les bibliothèques média

#### Bibliothèques Recommandées
```
Films     → /media/movies
Séries TV → /media/tv
Musique   → /media/music
Livres    → /media/books
```

#### Optimisations Performance
- **Transcodage** : Désactiver GPU, utiliser CPU
- **Qualité** : Limiter à 1080p max
- **Cache** : Activer mise en cache métadonnées

### 3. Sonarr (Gestion Séries)

#### Configuration Initiale
1. Accédez à http://votre-ip:8989
2. **Settings → Media Management**
   - Root Folder : `/tv`
   - Rename Episodes : ✅
   - Replace Illegal Characters : ✅

#### Profiles de Qualité
```
HD-1080p :
- HDTV-1080p
- WEB-1080p  
- Bluray-1080p
```

#### Download Clients
- **qBittorrent** : http://qbittorrent:8080
- **Category** : tv
- **Directory** : /downloads/tv

### 4. Radarr (Gestion Films)

#### Configuration Similaire à Sonarr
- Root Folder : `/movies`
- Category : movies
- Directory : /downloads/movies

#### Profiles Qualité Films
```
HD-1080p Movies :
- HDTV-1080p
- WEB-1080p
- Bluray-1080p
- Remux-1080p
```

### 5. Prowlarr (Indexeurs)

#### Indexeurs Publics Recommandés
- **YTS** (films)
- **EZTV** (séries)
- **1337x** (général)
- **RARBG** (qualité)

#### Configuration Apps
1. **Settings → Apps**
2. Ajouter Sonarr/Radarr
3. Synchroniser indexeurs automatiquement

### 6. qBittorrent

#### Configuration VPN
- **Network Interface** : tun0 (via Gluetun)
- **Bind to Interface** : ✅
- **Test** : Vérifier IP via http://votre-ip:8080

#### Paramètres Recommandés
```
Downloads :
- Default Save Path : /downloads
- Keep incomplete in : /downloads/incomplete

Speed :
- Upload Limit : 1 MB/s (ajustez selon votre connexion)
- Download Limit : Illimité

BitTorrent :
- Max Connections : 200
- Max Uploads : 10
```

### 7. Jellyseerr (Requêtes)

#### Connexion Jellyfin
1. Accédez à http://votre-ip:5055
2. Connectez-vous avec votre compte Jellyfin
3. **Settings → Jellyfin**
   - Server URL : http://jellyfin:8096

#### Connexion Services
- **Sonarr** : http://sonarr:8989
- **Radarr** : http://radarr:7878
- Utilisez les API Keys de chaque service

### 8. Bazarr (Sous-titres)

#### Configuration
1. **Settings → Languages**
   - Languages Filter : Français, Anglais
   - Default Enabled : ✅

2. **Settings → Providers**
   - OpenSubtitles
   - Subscene
   - TVSubtitles

#### Connexion Sonarr/Radarr
- Utiliser les mêmes URLs et API Keys

## Configuration Avancée

### SSL/HTTPS (Optionnel)

#### Avec Traefik
```yaml
# Ajouter au docker-compose.yml
traefik:
  image: traefik:v2.10
  command:
    - --certificatesresolvers.letsencrypt.acme.email=votre@email.com
```

### Monitoring

#### Portainer (Interface Docker)
```bash
docker run -d -p 9000:9000 --name portainer \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce
```

### Sauvegarde Automatique

#### Script de Sauvegarde
```bash
#!/bin/bash
# backup.sh
docker compose exec jellyfin tar -czf /config/backup-$(date +%Y%m%d).tar.gz /config
```

## Variables d'Environnement Complètes

```bash
# .env complet
VPN_SERVICE_PROVIDER=protonvpn
VPN_TYPE=openvpn
OPENVPN_USER=votre-username
OPENVPN_PASSWORD=votre-password
TZ=Europe/Paris
PUID=1000
PGID=1000

# Optionnel
DOMAIN=votre-domaine.com
EMAIL=votre@email.com
```

## Vérification Configuration

### Tests de Connectivité
```bash
# Test VPN
docker compose exec qbittorrent curl ifconfig.me

# Test services
curl http://localhost:8096/health
curl http://localhost:8989/api/v3/system/status
```

### Logs de Configuration
```bash
# Voir logs spécifiques
docker compose logs jellyfin
docker compose logs sonarr
docker compose logs gluetun
```

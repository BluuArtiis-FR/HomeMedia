# 🏗️ Architecture du Système

## Vue d'Ensemble

Le HomeLab Media Server utilise une architecture containerisée avec Docker Compose pour orchestrer tous les services.

## Schéma d'Architecture

```
Internet
    ↓
[ProtonVPN/Gluetun] ← Tunnel VPN sécurisé
    ↓
[Reverse Proxy] ← SSL/TLS automatique
    ↓
┌─────────────────────────────────────────────────────────┐
│                 HOMELAB MEDIA SERVER                    │
├─────────────────┬─────────────────┬─────────────────────┤
│   STREAMING     │   MANAGEMENT    │    DOWNLOAD         │
│                 │                 │                     │
│ • Jellyfin      │ • Sonarr        │ • qBittorrent       │
│   (8096)        │   (8989)        │   (8080)            │
│                 │                 │                     │
│ • Jellyseerr    │ • Radarr        │ • Prowlarr          │
│   (5055)        │   (7878)        │   (9696)            │
│                 │                 │                     │
│                 │ • Lidarr        │ • FlareSolverr      │
│                 │   (8686)        │   (8191)            │
│                 │                 │                     │
│                 │ • Readarr       │                     │
│                 │   (8787)        │                     │
│                 │                 │                     │
│                 │ • Bazarr        │                     │
│                 │   (6767)        │                     │
└─────────────────┴─────────────────┴─────────────────────┘
    ↓
[Stockage Partagé] ← Volumes Docker persistants
```

## Flux de Données

### 1. **Requête de Contenu**
```
Utilisateur → Jellyseerr → Sonarr/Radarr → Prowlarr → Indexeurs
```

### 2. **Téléchargement**
```
Indexeurs → qBittorrent (via VPN) → Stockage Local
```

### 3. **Post-traitement**
```
Sonarr/Radarr → Renommage/Organisation → Bazarr (sous-titres) → Jellyfin
```

### 4. **Streaming**
```
Jellyfin → Transcodage (CPU) → Client (Web/App)
```

## Sécurité

### Réseau
- **VPN obligatoire** pour qBittorrent
- **Firewall UFW** configuré automatiquement
- **Fail2Ban** protection anti-bruteforce
- **SSL/TLS** via Let's Encrypt

### Isolation
- Chaque service dans son propre container
- Volumes séparés pour données/config
- Réseau Docker isolé

## Performance

### Optimisations CPU
- **Transcodage matériel** désactivé (pas de GPU)
- **Profiles de qualité** optimisés 1080p
- **Cache intelligent** Jellyfin
- **Compression** activée

### Stockage
- **Volumes nommés** pour persistance
- **Montages bind** pour médias
- **Permissions** automatiquement configurées

## Monitoring

### Logs
```bash
# Voir tous les logs
docker compose logs -f

# Service spécifique
docker compose logs -f jellyfin
```

### Santé des Services
```bash
# Status des containers
docker compose ps

# Utilisation ressources
docker stats
```

## Scalabilité

### Ajout de Services
1. Modifier `docker-compose.yml`
2. Ajouter configuration dans `install.sh`
3. Mettre à jour firewall si nécessaire

### Stockage Externe
- Support NAS/SMB
- Montages réseau
- Stockage cloud (optionnel)

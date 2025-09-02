# 🔧 Guide de Dépannage

## Problèmes Courants

### 🚫 Services Inaccessibles

#### Symptôme
Les services ne répondent pas sur leurs ports

#### Solutions
```bash
# Vérifier status containers
docker compose ps

# Redémarrer services
docker compose restart

# Vérifier ports
sudo netstat -tulpn | grep :8096
```

### 🌐 VPN Non Fonctionnel

#### Symptôme
qBittorrent télécharge sans VPN

#### Diagnostic
```bash
# Vérifier IP qBittorrent
docker compose exec qbittorrent curl ifconfig.me

# Logs Gluetun
docker compose logs gluetun
```

#### Solutions
1. **Credentials VPN incorrects**
   ```bash
   # Modifier .env
   OPENVPN_USER=correct-username
   OPENVPN_PASSWORD=correct-password

   # Redémarrer
   docker compose restart gluetun qbittorrent
   ```

2. **Serveur VPN indisponible**
   ```bash
   # Changer de serveur dans docker-compose.yml
   SERVER_COUNTRIES=Netherlands,Switzerland
   ```

### 📁 Problèmes de Permissions

#### Symptôme
Erreurs d'accès aux fichiers

#### Solutions
```bash
# Corriger permissions
sudo chown -R $USER:$USER /opt/homelab
sudo chmod -R 755 /opt/homelab

# Vérifier PUID/PGID
id $USER
# Mettre à jour .env si nécessaire
```

### 🔍 Prowlarr - Indexeurs Bloqués

#### Symptôme
Indexeurs en erreur, pas de résultats

#### Solutions
1. **Activer FlareSolverr**
   ```bash
   # Dans Prowlarr → Settings → Indexers
   FlareSolverr URL: http://flaresolverr:8191
   ```

2. **Tester indexeurs**
   - Prowlarr → Indexers → Test
   - Supprimer indexeurs défaillants

### 💾 Espace Disque Insuffisant

#### Diagnostic
```bash
# Vérifier espace
df -h
docker system df

# Nettoyer Docker
docker system prune -a
```

#### Solutions
- Configurer rotation logs
- Supprimer anciens téléchargements
- Ajouter stockage externe

### 🎬 Jellyfin - Problèmes de Lecture

#### Symptôme
Vidéos ne se lancent pas ou lag

#### Solutions
1. **Transcodage CPU**
   ```
   Jellyfin → Dashboard → Playback
   - Hardware acceleration: None
   - Enable hardware encoding: ❌
   ```

2. **Qualité réseau**
   ```
   Client Settings:
   - Max streaming bitrate: 20 Mbps
   - Allow direct play: ✅
   ```

### 🔄 Services qui Redémarrent en Boucle

#### Diagnostic
```bash
# Logs détaillés
docker compose logs --tail=50 nom-service

# Vérifier ressources
docker stats
```

#### Causes Communes
- **Mémoire insuffisante** → Augmenter RAM
- **Configuration invalide** → Vérifier .env
- **Ports conflictuels** → Changer ports

## Commandes de Dépannage

### Redémarrage Sélectif
```bash
# Service spécifique
docker compose restart jellyfin

# Groupe de services
docker compose restart sonarr radarr lidarr

# Tout redémarrer
docker compose down && docker compose up -d
```

### Réinitialisation Service
```bash
# Arrêter service
docker compose stop jellyfin

# Supprimer container (garde config)
docker compose rm jellyfin

# Redémarrer
docker compose up -d jellyfin
```

### Logs Avancés
```bash
# Logs en temps réel
docker compose logs -f --tail=100

# Logs spécifique avec timestamps
docker compose logs -t jellyfin

# Exporter logs
docker compose logs > debug.log
```

## Problèmes Réseau

### Test Connectivité
```bash
# Test interne containers
docker compose exec jellyfin ping sonarr
docker compose exec sonarr ping prowlarr

# Test externe
docker compose exec gluetun ping 8.8.8.8
```

### Firewall UFW
```bash
# Status
sudo ufw status verbose

# Réinitialiser si problème
sudo ufw --force reset
sudo ufw enable
```

## Performance

### Monitoring Ressources
```bash
# CPU/RAM par container
docker stats --no-stream

# Espace disque
du -sh /opt/homelab/*

# Logs volumineux
sudo journalctl --disk-usage
sudo journalctl --vacuum-size=100M
```

### Optimisations
```bash
# Limiter logs Docker
# Dans /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

## Support

### Collecte d'Informations
```bash
# Informations système
./debug-info.sh > system-info.txt
```

### Logs Utiles
- Docker Compose : `docker compose logs`
- Système : `journalctl -u docker`
- UFW : `sudo tail /var/log/ufw.log`
- Fail2Ban : `sudo tail /var/log/fail2ban.log`

### Communauté
- GitHub Issues
- Discord HomeLab
- Reddit r/selfhosted

## Désinstallation

### Arrêt des Services
```bash
docker compose down -v
```

### Suppression Complète
```bash
sudo rm -rf /opt/homelab
docker system prune -a --volumes
```

⚠️ **Attention** : Cela supprimera toutes vos données !

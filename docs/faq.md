# ❓ Questions Fréquentes (FAQ)

## 🎯 Général

### Q: Puis-je utiliser ce setup sans VPN ?
**R:** Techniquement oui, mais **fortement déconseillé** pour des raisons légales. Le VPN est intégré par défaut pour votre protection.

### Q: Ça fonctionne sur Raspberry Pi ?
**R:** Oui, mais performances limitées. Recommandé : Pi 4 8GB minimum. Certains services peuvent être lents.

### Q: Combien d'espace disque nécessaire ?
**R:** 
- **Système** : 50 GB minimum
- **Médias** : Selon vos besoins (1 TB+ recommandé)
- **Config/Logs** : ~5 GB

## 🔧 Installation

### Q: L'installation échoue sur Ubuntu 18.04
**R:** Ubuntu 18.04 n'est plus supporté. Utilisez Ubuntu 20.04+ ou Debian 11+.

### Q: Erreur "Permission denied" pendant l'installation
**R:** 
```bash
# Vérifiez que vous êtes dans le groupe docker
groups $USER

# Si pas présent :
sudo usermod -aG docker $USER
newgrp docker
```

### Q: Les ports sont déjà utilisés
**R:**
```bash
# Identifier le service conflictuel
sudo netstat -tulpn | grep :8096

# Arrêter le service
sudo systemctl stop nom-du-service

# Ou modifier les ports dans docker-compose.yml
```

## 🌐 VPN & Sécurité

### Q: Quel VPN utiliser ?
**R:** ProtonVPN est configuré par défaut, mais Gluetun supporte :
- ProtonVPN ✅
- NordVPN ✅  
- ExpressVPN ✅
- Surfshark ✅
- [Liste complète](https://github.com/qdm12/gluetun/wiki)

### Q: Comment vérifier que le VPN fonctionne ?
**R:**
```bash
# IP sans VPN
curl ifconfig.me

# IP avec VPN (doit être différente)
docker compose exec qbittorrent curl ifconfig.me
```

### Q: Fail2Ban bloque mon IP
**R:**
```bash
# Débloquer votre IP
sudo fail2ban-client set sshd unbanip VOTRE-IP

# Voir IPs bloquées
sudo fail2ban-client status sshd
```

## 📺 Jellyfin

### Q: Vidéos ne se lisent pas / lag
**R:** 
1. **Désactiver transcodage GPU** (Dashboard → Playback)
2. **Limiter qualité** client à 1080p max
3. **Vérifier format** : MP4/MKV recommandés

### Q: Pas de métadonnées pour mes films
**R:**
1. **Nommage correct** : `Film (2023).mp4`
2. **Structure dossiers** : `/movies/Film (2023)/Film (2023).mp4`
3. **Scan bibliothèque** : Dashboard → Libraries → Scan

### Q: Sous-titres manquants
**R:** Bazarr s'en charge automatiquement. Vérifiez :
- Bazarr → Settings → Languages
- Providers activés
- Connexion Sonarr/Radarr OK

## ⬇️ Téléchargements

### Q: qBittorrent ne télécharge pas
**R:**
1. **Vérifier VPN** : `docker compose logs gluetun`
2. **Tester indexeurs** : Prowlarr → Test
3. **Vérifier espace disque** : `df -h`

### Q: Téléchargements lents
**R:**
```bash
# Dans qBittorrent Web UI
Settings → Speed :
- Upload limit : 1-2 MB/s
- Download limit : Unlimited
- Max connections : 200
```

### Q: Sonarr/Radarr ne trouvent rien
**R:**
1. **Prowlarr configuré** avec indexeurs
2. **Apps synchronisées** dans Prowlarr
3. **Profiles qualité** corrects
4. **Test manuel** dans Prowlarr

## 🔄 Maintenance

### Q: Comment sauvegarder mes configurations ?
**R:**
```bash
# Sauvegarde complète
tar -czf homelab-backup.tar.gz /opt/homelab/config

# Restauration
tar -xzf homelab-backup.tar.gz -C /
```

### Q: Comment mettre à jour ?
**R:**
```bash
# Arrêter services
docker compose down

# Mettre à jour images
docker compose pull

# Redémarrer
docker compose up -d
```

### Q: Nettoyer l'espace disque
**R:**
```bash
# Nettoyer Docker
docker system prune -a

# Nettoyer téléchargements anciens
find /opt/homelab/downloads -mtime +30 -delete

# Logs système
sudo journalctl --vacuum-size=100M
```

## 🎵 Services Spécialisés

### Q: Lidarr ne trouve pas de musique
**R:** 
- Indexeurs musique spécialisés requis
- Configuration Spotify/Last.fm pour métadonnées
- Formats : FLAC, MP3 320kbps

### Q: Readarr pour les livres
**R:**
- Indexeurs ebooks : MAM, Libgen
- Formats : EPUB, PDF, MOBI
- Calibre-web en complément recommandé

## 🚨 Urgences

### Q: Plus rien ne fonctionne !
**R:**
```bash
# Diagnostic rapide
docker compose ps
docker compose logs --tail=20

# Reset complet (ATTENTION : perte config)
docker compose down -v
docker system prune -a
sudo rm -rf /opt/homelab
# Puis réinstaller
```

### Q: Serveur compromis ?
**R:**
1. **Déconnecter internet** immédiatement
2. **Arrêter services** : `docker compose down`
3. **Analyser logs** : `/var/log/auth.log`
4. **Changer mots de passe** VPN/services
5. **Réinstaller** si nécessaire

## 📞 Obtenir de l'Aide

### Informations à Fournir
```bash
# Générer rapport debug
docker compose ps > debug-report.txt
docker compose logs >> debug-report.txt
uname -a >> debug-report.txt
df -h >> debug-report.txt
```

### Communautés
- **GitHub Issues** : Bugs spécifiques au projet
- **r/selfhosted** : Communauté générale
- **Discord HomeLab** : Support temps réel
- **LinuxServer.io** : Documentation containers

---

💡 **Astuce** : La plupart des problèmes se résolvent avec un simple `docker compose restart` !

# 📚 Index de la Documentation - HomeLab Media Server

## 🎯 Par où commencer ?

### 🆕 Nouvelle installation
👉 **Commencez ici : [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md)** (5 min de lecture)

### 📖 Installation détaillée
👉 **Guide complet : [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md)** (référence complète)

### 🔍 Vue d'ensemble du projet
👉 **README : [README.md](README.md)** (présentation générale)

---

## 📁 Organisation de la documentation

### 🚀 Guides d'installation

| Fichier | Description | Durée | Niveau |
|---------|-------------|-------|--------|
| [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md) | Guide rapide de réinstallation | 5 min | Débutant ⭐ |
| [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) | Guide complet avec tous les détails | 20 min | Intermédiaire ⭐⭐ |
| [INSTALLATION_PAS_A_PAS.md](INSTALLATION_PAS_A_PAS.md) | Installation initiale étape par étape | 15 min | Débutant ⭐ |
| [DEBIAN_12_GUIDE.md](DEBIAN_12_GUIDE.md) | Spécificités Debian 12 | 10 min | Débutant ⭐ |
| [GUIDE_DEPLOIEMENT_VM.md](GUIDE_DEPLOIEMENT_VM.md) | Déploiement sur VM (VirtualBox, VMware, etc.) | 10 min | Débutant ⭐ |

### 🔧 Corrections et mises à jour

| Fichier | Description | Public |
|---------|-------------|--------|
| [RESUME_CORRECTIONS.md](RESUME_CORRECTIONS.md) | Résumé des corrections v2.0.0 | Tous ⭐ |
| [CORRECTIONS_PROJET.md](CORRECTIONS_PROJET.md) | Détails techniques des corrections | Avancé ⭐⭐⭐ |
| [CHANGELOG.md](CHANGELOG.md) | Historique des versions | Tous ⭐ |

### 📖 Documentation générale

| Fichier | Description | Public |
|---------|-------------|--------|
| [README.md](README.md) | Présentation du projet | Tous ⭐ |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Guide de contribution | Développeurs ⭐⭐ |
| [LICENSE](LICENSE) | Licence MIT | Tous ⭐ |
| [STRUCTURE.md](STRUCTURE.md) | Structure du projet | Développeurs ⭐⭐ |

### 🛠️ Validation et tests

| Fichier | Description | Public |
|---------|-------------|--------|
| [VALIDATION_REPORT.md](VALIDATION_REPORT.md) | Rapport de validation complet | Tous ⭐ |
| [health-check.sh](health-check.sh) | Script de diagnostic système | Administrateurs ⭐⭐ |

### ⚙️ Configuration

| Fichier | Description | Obligatoire |
|---------|-------------|-------------|
| [.env.example](.env.example) | Template de configuration | Oui ✅ |
| [docker-compose.yml](docker-compose.yml) | Configuration Docker Compose | Oui ✅ |
| [Makefile](Makefile) | Commandes simplifiées | Non |

### 🔨 Scripts d'installation

| Fichier | Description | Usage |
|---------|-------------|-------|
| [install.sh](install.sh) | Installation automatique complète | `sudo ./install.sh` |
| [generate-compose.sh](generate-compose.sh) | Générateur Docker Compose modulaire | `./generate-compose.sh` |

---

## 🗺️ Parcours selon votre situation

### Situation 1 : Première installation sur VM Debian 12

1. Lire [README.md](README.md) pour comprendre le projet
2. Lire [GUIDE_DEPLOIEMENT_VM.md](GUIDE_DEPLOIEMENT_VM.md) pour les spécifications VM
3. Suivre [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md) étape par étape
4. En cas de problème, consulter [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) section Dépannage

**Durée estimée : 45 minutes**

---

### Situation 2 : Installation existante avec problèmes

1. Lire [RESUME_CORRECTIONS.md](RESUME_CORRECTIONS.md) pour comprendre les corrections
2. Sauvegarder vos données (voir [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) section 1)
3. Suivre [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md) pour réinstaller
4. Consulter [CORRECTIONS_PROJET.md](CORRECTIONS_PROJET.md) pour les détails techniques

**Durée estimée : 1 heure**

---

### Situation 3 : Mise à jour depuis version 1.0.0

1. Lire [CHANGELOG.md](CHANGELOG.md) pour voir les nouveautés v2.0.0
2. Décider entre mise à jour simple ou réinstallation complète
3. Mise à jour simple : voir [RESUME_CORRECTIONS.md](RESUME_CORRECTIONS.md) section "Option 1"
4. Réinstallation : suivre [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md)

**Durée estimée : 30-60 minutes**

---

### Situation 4 : Développeur souhaitant contribuer

1. Lire [README.md](README.md) et [STRUCTURE.md](STRUCTURE.md)
2. Lire [CONTRIBUTING.md](CONTRIBUTING.md)
3. Consulter [CHANGELOG.md](CHANGELOG.md) pour comprendre l'évolution
4. Consulter [CORRECTIONS_PROJET.md](CORRECTIONS_PROJET.md) pour voir les modifications récentes

---

### Situation 5 : Problème spécifique à résoudre

#### Erreur "Name does not resolve" (Prowlarr → Radarr/Sonarr)
📖 [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section 5.4 + Tableau URLs

#### VPN ne fonctionne pas
📖 [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section Dépannage VPN

#### qBittorrent "Unauthorized"
📖 [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md) - Section Problèmes fréquents

#### Container ne démarre pas
📖 [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section Dépannage

#### Port déjà utilisé
📖 [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section Dépannage

#### Bibliothèque anime non reconnue
📖 [RESUME_CORRECTIONS.md](RESUME_CORRECTIONS.md) - Structure des dossiers

---

## 🎯 Documents par niveau de compétence

### 👶 Débutant

Recommandé pour ceux qui découvrent Docker, Linux, ou les serveurs média :

1. [README.md](README.md) - Vue d'ensemble
2. [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md) - Installation rapide
3. [GUIDE_DEPLOIEMENT_VM.md](GUIDE_DEPLOIEMENT_VM.md) - Configuration VM
4. [INSTALLATION_PAS_A_PAS.md](INSTALLATION_PAS_A_PAS.md) - Détails étape par étape

### 🧑 Intermédiaire

Pour ceux ayant une expérience de base en Linux/Docker :

1. [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Guide complet
2. [RESUME_CORRECTIONS.md](RESUME_CORRECTIONS.md) - Résumé technique
3. [VALIDATION_REPORT.md](VALIDATION_REPORT.md) - Rapport de validation
4. [.env.example](.env.example) - Configuration avancée

### 👨‍💻 Avancé

Pour administrateurs système et développeurs :

1. [CORRECTIONS_PROJET.md](CORRECTIONS_PROJET.md) - Modifications ligne par ligne
2. [STRUCTURE.md](STRUCTURE.md) - Architecture du projet
3. [docker-compose.yml](docker-compose.yml) - Configuration Docker
4. [install.sh](install.sh) - Script d'installation
5. [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution au projet

---

## 📊 Documents par type de besoin

### 🔍 Comprendre le projet

- [README.md](README.md) - Présentation générale
- [STRUCTURE.md](STRUCTURE.md) - Organisation du code
- [CHANGELOG.md](CHANGELOG.md) - Évolution du projet

### 🚀 Installer le projet

- [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md) - Installation rapide (RECOMMANDÉ)
- [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Installation complète
- [DEBIAN_12_GUIDE.md](DEBIAN_12_GUIDE.md) - Spécificités Debian

### ⚙️ Configurer les services

- [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section 5 (Configuration)
- [.env.example](.env.example) - Variables d'environnement
- [docker-compose.yml](docker-compose.yml) - Services Docker

### 🐛 Résoudre des problèmes

- [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md) - Section Problèmes fréquents
- [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section Dépannage
- [CORRECTIONS_PROJET.md](CORRECTIONS_PROJET.md) - Erreurs et fixes

### 📈 Comprendre les mises à jour

- [CHANGELOG.md](CHANGELOG.md) - Historique des versions
- [RESUME_CORRECTIONS.md](RESUME_CORRECTIONS.md) - Résumé v2.0.0
- [CORRECTIONS_PROJET.md](CORRECTIONS_PROJET.md) - Détails techniques

### 🤝 Contribuer au projet

- [CONTRIBUTING.md](CONTRIBUTING.md) - Guide de contribution
- [LICENSE](LICENSE) - Licence MIT
- [STRUCTURE.md](STRUCTURE.md) - Architecture du code

---

## 🔗 Liens utiles dans la documentation

### Tableaux de référence

- **URLs Docker** : [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section "Récapitulatif des URLs"
- **Ports des services** : [README.md](README.md) - Section "Services Inclus"
- **Problèmes résolus** : [CORRECTIONS_PROJET.md](CORRECTIONS_PROJET.md) - Section "Problèmes résolus"

### Checklists

- **Installation complète** : [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section "Checklist finale"
- **Installation rapide** : [MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md) - Section "Checklist finale"
- **Validation** : [VALIDATION_REPORT.md](VALIDATION_REPORT.md) - Tests de validation

### Procédures pas à pas

- **Nettoyage VM** : [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section 2
- **Configuration Prowlarr** : [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section 5.4
- **Création bibliothèques Jellyfin** : [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) - Section 5.1

---

## 📞 Support et aide

### En cas de problème

1. **Consulter la documentation** : Parcourir l'index ci-dessus selon votre situation
2. **Vérifier les logs** : `docker compose logs SERVICE_NAME`
3. **Lancer le health check** : `./health-check.sh`
4. **Consulter le dépannage** : [VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md) section Dépannage

### Fichiers à fournir pour le support

Si vous demandez de l'aide, préparez :
- Sortie de `docker compose ps`
- Sortie de `docker compose logs`
- Contenu du fichier `.env` (masquer les credentials VPN)
- Description précise du problème

---

## 🎉 Récapitulatif

### Fichiers essentiels (à lire en priorité)

1. **[README.md](README.md)** - Vue d'ensemble du projet
2. **[MARCHE_A_SUIVRE.md](MARCHE_A_SUIVRE.md)** - Installation rapide
3. **[VM_REINSTALL_COMPLETE.md](VM_REINSTALL_COMPLETE.md)** - Guide complet

### Fichiers de référence

- **[RESUME_CORRECTIONS.md](RESUME_CORRECTIONS.md)** - Résumé des corrections v2.0.0
- **[CHANGELOG.md](CHANGELOG.md)** - Historique des versions
- **[.env.example](.env.example)** - Configuration

### Fichiers techniques

- **[docker-compose.yml](docker-compose.yml)** - Services Docker
- **[install.sh](install.sh)** - Installation automatique
- **[CORRECTIONS_PROJET.md](CORRECTIONS_PROJET.md)** - Modifications détaillées

---

**Version de l'index : 2.0.0**
**Dernière mise à jour : 2025-10-05**

# 🤝 Guide de Contribution

Merci de votre intérêt pour contribuer au HomeLab Media Server ! Ce guide vous aidera à démarrer.

## 📋 Table des Matières
- [Code de Conduite](#code-de-conduite)
- [Comment Contribuer](#comment-contribuer)
- [Processus de Pull Request](#processus-de-pull-request)
- [Standards de Code](#standards-de-code)
- [Structure du Projet](#structure-du-projet)
- [Signaler un Bug](#signaler-un-bug)
- [Proposer une Fonctionnalité](#proposer-une-fonctionnalité)

## 🌟 Code de Conduite

Ce projet adhère à un code de conduite simple : **soyez respectueux et constructif**. Les contributions de toutes les personnes sont les bienvenues, quels que soient leur niveau d'expérience ou leur origine.

## 🚀 Comment Contribuer

### Types de Contributions Acceptées

- 🐛 **Corrections de bugs**
- ✨ **Nouvelles fonctionnalités**
- 📝 **Améliorations de documentation**
- 🎨 **Améliorations UX/UI**
- 🔒 **Améliorations de sécurité**
- ⚡ **Optimisations de performance**
- 🌍 **Traductions**

### Première Contribution ?

1. **Fork le repository** sur votre compte GitHub
2. **Clone votre fork** localement
   ```bash
   git clone https://github.com/VOTRE-USERNAME/homelab-media-server.git
   cd homelab-media-server
   ```
3. **Créez une branche** pour vos modifications
   ```bash
   git checkout -b feature/ma-super-fonctionnalite
   ```
4. **Faites vos modifications** et testez-les
5. **Commitez vos changements**
   ```bash
   git add .
   git commit -m "feat: ajout de ma super fonctionnalité"
   ```
6. **Poussez vers votre fork**
   ```bash
   git push origin feature/ma-super-fonctionnalite
   ```
7. **Ouvrez une Pull Request** sur le repository principal

## 🔄 Processus de Pull Request

### Avant de Soumettre

- ✅ Vérifiez que votre code fonctionne
- ✅ Testez sur un environnement propre
- ✅ Assurez-vous qu'il n'y a pas de conflits avec `main`
- ✅ Mettez à jour la documentation si nécessaire
- ✅ Suivez les standards de code du projet

### Format du Titre de PR

Utilisez les préfixes conventionnels :

- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `docs:` - Documentation uniquement
- `style:` - Formatage, point-virgule manquant, etc.
- `refactor:` - Refactoring de code
- `test:` - Ajout de tests
- `chore:` - Maintenance, dépendances, etc.

**Exemple :** `feat: ajout du support Wireguard pour le VPN`

### Description de la PR

Incluez dans votre PR :

```markdown
## Description
Brève description des changements

## Type de Changement
- [ ] Bug fix (changement non-breaking qui corrige un problème)
- [ ] Nouvelle fonctionnalité (changement non-breaking qui ajoute une fonctionnalité)
- [ ] Breaking change (correction ou fonctionnalité qui causerait un dysfonctionnement des fonctionnalités existantes)
- [ ] Mise à jour de documentation

## Comment Tester
1. Étape 1
2. Étape 2
3. Résultat attendu

## Checklist
- [ ] Mon code suit les standards du projet
- [ ] J'ai testé mes modifications
- [ ] J'ai mis à jour la documentation
- [ ] Mes commits suivent les conventions
```

## 📏 Standards de Code

### Scripts Bash

- **Shebang** : `#!/bin/bash`
- **Set options** : `set -euo pipefail`
- **Indentation** : 4 espaces (pas de tabs)
- **Variables** : UPPERCASE pour constantes, lowercase pour variables
- **Fonctions** : snake_case avec commentaires

```bash
#!/bin/bash
set -euo pipefail

# Description de la fonction
ma_fonction() {
    local param=$1
    echo "Traitement de ${param}"
}
```

### Docker Compose

- **Version** : 3.8 minimum
- **Indentation** : 2 espaces
- **Ordre** : services → networks → volumes
- **Commentaires** : Documenter les services complexes

### Documentation

- **Format** : Markdown (GitHub Flavored)
- **Langue** : Français pour ce projet
- **Structure** : Titres clairs, exemples de code, liens internes

## 🗂️ Structure du Projet

```
homelab-media-server/
├── docs/              # Documentation détaillée
├── .env.example       # Template de configuration
├── generate-compose.sh # Générateur modulaire
├── install.sh         # Script d'installation
├── docker-compose.yml # Composition Docker par défaut
├── health-check.sh    # Vérification santé système
├── LICENSE            # Licence MIT
├── README.md          # Documentation principale
└── CONTRIBUTING.md    # Ce fichier
```

## 🐛 Signaler un Bug

### Avant de Signaler

1. **Vérifiez** que le bug n'a pas déjà été signalé
2. **Testez** sur la dernière version
3. **Collectez** les informations système

### Créer un Bug Report

Utilisez ce template :

```markdown
**Description du Bug**
Description claire et concise du problème.

**Étapes pour Reproduire**
1. Commande exécutée '...'
2. Action effectuée '...'
3. Erreur observée

**Comportement Attendu**
Ce qui devrait se passer normalement.

**Logs/Screenshots**
```bash
# Coller les logs pertinents
```

**Environnement**
- OS : [ex: Ubuntu 22.04]
- Docker : [version]
- Services affectés : [liste]

**Informations Additionnelles**
Tout contexte supplémentaire utile.
```

## 💡 Proposer une Fonctionnalité

### Template de Feature Request

```markdown
**Problème Résolu**
Description du problème que cette fonctionnalité résoudrait.

**Solution Proposée**
Description claire de votre solution.

**Alternatives Considérées**
Autres approches que vous avez envisagées.

**Contexte Additionnel**
Screenshots, exemples, références.
```

## 🧪 Tests

Avant de soumettre :

```bash
# Génération du compose
./generate-compose.sh

# Validation Docker
docker compose config

# Démarrage test
docker compose up -d

# Vérification santé
./health-check.sh

# Nettoyage
docker compose down -v
```

## 📞 Questions ?

- **Issues GitHub** : Pour bugs et features
- **Discussions** : Pour questions générales
- **Pull Requests** : Référencer toujours un issue si possible

## 🙏 Remerciements

Merci à tous les contributeurs qui aident à améliorer ce projet !

---

**Rappel** : Toute contribution implique l'acceptation de la licence MIT du projet.

# 🏠 HomeLab Media Server - Makefile
# Commandes simplifiées pour gérer le serveur

.PHONY: help install start stop restart status logs health update clean backup

# Couleurs
GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[0;34m
NC     := \033[0m

# Variables
COMPOSE := docker compose
SERVICES := jellyfin jellyseerr sonarr radarr qbittorrent prowlarr bazarr gluetun

##@ 🚀 Installation et Configuration

help: ## Afficher l'aide
	@echo "$(BLUE)╔══════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     🏠 HomeLab Media Server - Commandes Make        ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make $(YELLOW)<target>$(NC)\n\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

install: ## Installer le serveur (requiert sudo)
	@echo "$(BLUE)🔧 Installation du HomeLab Media Server...$(NC)"
	@chmod +x install.sh generate-compose.sh health-check.sh
	@sudo ./install.sh

config: ## Configurer l'environnement (.env)
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN)✅ Fichier .env créé à partir du template$(NC)"; \
		echo "$(YELLOW)⚠️  Modifiez .env avec vos credentials VPN$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  .env existe déjà$(NC)"; \
	fi

generate: ## Générer docker-compose.yml personnalisé
	@echo "$(BLUE)🔧 Génération docker-compose.yml...$(NC)"
	@./generate-compose.sh

##@ 🐳 Gestion Docker

start: ## Démarrer tous les services
	@echo "$(BLUE)🚀 Démarrage des services...$(NC)"
	@$(COMPOSE) up -d
	@echo "$(GREEN)✅ Services démarrés$(NC)"
	@make --no-print-directory urls

stop: ## Arrêter tous les services
	@echo "$(YELLOW)🛑 Arrêt des services...$(NC)"
	@$(COMPOSE) down
	@echo "$(GREEN)✅ Services arrêtés$(NC)"

restart: ## Redémarrer tous les services
	@echo "$(BLUE)🔄 Redémarrage des services...$(NC)"
	@$(COMPOSE) restart
	@echo "$(GREEN)✅ Services redémarrés$(NC)"

status: ## Afficher l'état des services
	@echo "$(BLUE)📊 État des Services Docker:$(NC)"
	@$(COMPOSE) ps

##@ 📊 Monitoring et Logs

logs: ## Voir les logs de tous les services
	@$(COMPOSE) logs -f

logs-%: ## Voir les logs d'un service spécifique (ex: make logs-jellyfin)
	@$(COMPOSE) logs -f $*

health: ## Vérifier la santé du système
	@./health-check.sh

urls: ## Afficher les URLs des services
	@echo "$(GREEN)🌐 Services accessibles sur:$(NC)"
	@echo "  $(BLUE)Jellyfin:$(NC)    http://$$(hostname -I | awk '{print $$1}'):8096"
	@echo "  $(BLUE)Jellyseerr:$(NC)  http://$$(hostname -I | awk '{print $$1}'):5055"
	@echo "  $(BLUE)Sonarr:$(NC)      http://$$(hostname -I | awk '{print $$1}'):8989"
	@echo "  $(BLUE)Radarr:$(NC)      http://$$(hostname -I | awk '{print $$1}'):7878"
	@echo "  $(BLUE)qBittorrent:$(NC) http://$$(hostname -I | awk '{print $$1}'):8080"
	@echo "  $(BLUE)Prowlarr:$(NC)    http://$$(hostname -I | awk '{print $$1}'):9696"
	@echo "  $(BLUE)Bazarr:$(NC)      http://$$(hostname -I | awk '{print $$1}'):6767"

stats: ## Afficher les statistiques de ressources
	@docker stats --no-stream

##@ 🔄 Mises à Jour

update: ## Mettre à jour les images Docker
	@echo "$(BLUE)📥 Téléchargement des mises à jour...$(NC)"
	@$(COMPOSE) pull
	@echo "$(BLUE)🔄 Redémarrage avec nouvelles images...$(NC)"
	@$(COMPOSE) up -d
	@echo "$(GREEN)✅ Mise à jour terminée$(NC)"

update-%: ## Mettre à jour un service spécifique (ex: make update-jellyfin)
	@echo "$(BLUE)📥 Mise à jour de $*...$(NC)"
	@$(COMPOSE) pull $*
	@$(COMPOSE) up -d $*
	@echo "$(GREEN)✅ $* mis à jour$(NC)"

##@ 🧹 Maintenance

clean: ## Nettoyer les ressources Docker inutilisées
	@echo "$(YELLOW)🧹 Nettoyage des ressources Docker...$(NC)"
	@docker system prune -f
	@echo "$(GREEN)✅ Nettoyage terminé$(NC)"

clean-all: ## Nettoyer TOUT (containers, volumes, images)
	@echo "$(YELLOW)⚠️  ATTENTION: Cela va supprimer TOUS les containers, volumes et images !$(NC)"
	@read -p "Êtes-vous sûr ? (tapez 'oui' pour confirmer): " confirm; \
	if [ "$$confirm" = "oui" ]; then \
		$(COMPOSE) down -v; \
		docker system prune -a -f; \
		echo "$(GREEN)✅ Nettoyage complet terminé$(NC)"; \
	else \
		echo "$(YELLOW)❌ Annulé$(NC)"; \
	fi

##@ 💾 Sauvegarde

backup: ## Créer une sauvegarde des configurations
	@echo "$(BLUE)💾 Création de la sauvegarde...$(NC)"
	@mkdir -p backups
	@tar -czf backups/homelab-config-$$(date +%Y%m%d-%H%M%S).tar.gz \
		-C /opt/homelab config 2>/dev/null || \
		tar -czf backups/homelab-config-$$(date +%Y%m%d-%H%M%S).tar.gz config/
	@echo "$(GREEN)✅ Sauvegarde créée dans backups/$(NC)"

restore: ## Restaurer la dernière sauvegarde
	@echo "$(YELLOW)⚠️  Restauration de la dernière sauvegarde...$(NC)"
	@latest=$$(ls -t backups/*.tar.gz 2>/dev/null | head -1); \
	if [ -n "$$latest" ]; then \
		tar -xzf $$latest -C /opt/homelab/ 2>/dev/null || tar -xzf $$latest; \
		echo "$(GREEN)✅ Restauration depuis: $$latest$(NC)"; \
	else \
		echo "$(YELLOW)❌ Aucune sauvegarde trouvée$(NC)"; \
	fi

##@ 🛠️ Développement

shell-%: ## Ouvrir un shell dans un container (ex: make shell-jellyfin)
	@$(COMPOSE) exec $* /bin/bash || $(COMPOSE) exec $* /bin/sh

rebuild: ## Reconstruire tous les containers
	@echo "$(BLUE)🔨 Reconstruction des containers...$(NC)"
	@$(COMPOSE) up -d --build --force-recreate
	@echo "$(GREEN)✅ Reconstruction terminée$(NC)"

validate: ## Valider la configuration docker-compose
	@echo "$(BLUE)✔️  Validation de la configuration...$(NC)"
	@$(COMPOSE) config > /dev/null
	@echo "$(GREEN)✅ Configuration valide$(NC)"

##@ 🔒 Sécurité

check-vpn: ## Vérifier que le VPN fonctionne
	@echo "$(BLUE)🔒 Vérification VPN...$(NC)"
	@echo "$(YELLOW)IP via VPN:$(NC)"
	@docker exec gluetun wget -qO- https://api.ipify.org || echo "$(YELLOW)Container gluetun non démarré$(NC)"
	@echo ""
	@echo "$(YELLOW)Votre IP réelle:$(NC)"
	@curl -s https://api.ipify.org
	@echo ""
	@echo "$(GREEN)Les deux IPs doivent être différentes !$(NC)"

test-firewall: ## Tester la configuration du pare-feu
	@echo "$(BLUE)🛡️  Configuration UFW:$(NC)"
	@sudo ufw status verbose || echo "$(YELLOW)UFW non installé$(NC)"

##@ 📖 Documentation

docs: ## Ouvrir la documentation
	@echo "$(BLUE)📖 Documentation disponible:$(NC)"
	@echo "  - README.md (vue d'ensemble)"
	@echo "  - docs/quick-start.md (démarrage rapide)"
	@echo "  - docs/installation.md (installation détaillée)"
	@echo "  - docs/configuration.md (configuration)"
	@echo "  - docs/troubleshooting.md (dépannage)"

version: ## Afficher les versions
	@echo "$(BLUE)📦 Versions installées:$(NC)"
	@docker --version
	@docker compose version
	@echo ""
	@echo "$(BLUE)🐳 Images Docker:$(NC)"
	@docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "jellyfin|sonarr|radarr|qbittorrent|prowlarr|gluetun|bazarr|jellyseerr"

##@ 🎯 Raccourcis Pratiques

dev: start logs ## Démarrer et suivre les logs (mode développement)

full-restart: stop clean start health ## Arrêt complet, nettoyage, redémarrage et health check

quick-check: status urls ## Vérification rapide (status + URLs)

# Cibles par défaut
.DEFAULT_GOAL := help

# import .env file
include .env
export $(shell sed 's/=.*//' .env)

# Nom du conteneur MySQL
DB_CONTAINER=stockbuster-mysql
# Nom du fichier de sauvegarde de la base de données
EXPORT_FILE=backup.sql

# URL des dépôts Git
FRONTEND_REPO=git@github.com:StockBusterGit/Frontend.git
BACKEND_REPO=git@github.com:StockBusterGit/Backend.git

# Détection de la commande docker-compose
DOCKER_COMPOSE = $(shell if docker compose version > /dev/null 2>&1; then echo "docker compose"; else echo "docker-compose"; fi)

init:
	@if [ ! -d "./Frontend" ]; then \
		echo "Cloning Frontend repository..."; \
		git clone -b develop $(FRONTEND_REPO); \
	else \
		echo "Frontend repository already exists."; \
	fi
	@if [ -f "./Frontend/.env.example" ]; then \
		echo "Copying .env.example to .env in Frontend..."; \
		cp ./Frontend/.env.example ./Frontend/.env; \
	fi
	@if [ -d "./Frontend" ]; then \
		echo "Installing Frontend dependencies..."; \
		cd Frontend && npm install; \
	fi
	@if [ ! -d "./Backend" ]; then \
		echo "Cloning Backend repository..."; \
		git clone -b develop $(BACKEND_REPO); \
	else \
		echo "Backend repository already exists."; \
	fi
	@if [ -f "./Backend/.env.example" ]; then \
		echo "Copying .env.example to .env in Backend..."; \
		cp ./Backend/.env.example ./Backend/.env; \
	fi
	@if [ -d "./Backend" ]; then \
		echo "Installing Backend dependencies..."; \
		cd Backend && npm install; \
	fi

update:
	@echo "Updating current directory repository..."
	@git checkout develop && git pull

	@if [ -d "./Frontend" ]; then \
		echo "Updating Frontend repository..."; \
		cd Frontend && git checkout develop  && git pull; \
	fi
	@if [ -d "./Frontend" ]; then \
		echo "Installing Frontend dependencies..."; \
		cd Frontend && npm install; \
	fi
	@if [ -d "./Backend" ]; then \
		echo "Updating Backend repository..."; \
		cd Backend && git checkout develop  && git pull; \
	fi
	@if [ -d "./Backend" ]; then \
		echo "Installing Backend dependencies..."; \
		cd Backend && npm install; \
	fi

# Cible pour exporter la base de données depuis le conteneur MySQL
export-db:
	@echo "Exporting database from container $(DB_CONTAINER) to $(EXPORT_FILE)..."
	@docker exec $(DB_CONTAINER) sh -c "exec mysqldump -u $(MYSQL_USERNAME) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE)" > $(EXPORT_FILE)
	@echo "Database exported to $(EXPORT_FILE)."

# Cible pour importer la base de données dans le conteneur MySQL
import-db:
	@echo "Importing database from $(EXPORT_FILE) to container $(DB_CONTAINER)..."
	@docker exec -i $(DB_CONTAINER) sh -c "exec mysql -u $(MYSQL_USERNAME) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE)" < $(EXPORT_FILE)
	@echo "Database imported from $(EXPORT_FILE)."

start:
	$(DOCKER_COMPOSE)  up -d

stop:
	$(DOCKER_COMPOSE)  down

restart: stop start

logs:
	$(DOCKER_COMPOSE)  logs -f

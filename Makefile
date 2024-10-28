FRONTEND_REPO=git@github.com:StockBusterGit/Frontend.git
BACKEND_REPO=git@github.com:StockBusterGit/Backend.git

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

start:
	docker-compose up -d

stop:
	docker-compose down

restart: stop start

logs:
	docker-compose logs -f

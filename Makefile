NAME        = inception
SRCS        = ./srcs
COMPOSE     = $(SRCS)/docker-compose.yml
HOST_URL    = jmigoya-.42.fr
DATA_DIR    = /home/jmigoya-/data
HIDE        = /dev/null 2>&1

all: sudo_check up

sudo_check:
	@if [ "$$EUID" -ne 0 ]; then echo "Please run 'make' with sudo"; exit 1; fi

up: restore create_dirs
	@sudo hostsed add 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_ADDED)"
	@sudo docker compose -p $(NAME) -f $(COMPOSE) up --build || (echo " $(BUILD_INTERRUPTED)" && exit 1)
	@echo " $(CONTAINERS_STARTED)"

down:
	@sudo docker compose -p $(NAME) down
	@echo " $(CONTAINERS_STOPPED)"

backup:
	@if [ -d ~/data ]; then sudo tar -czvf ~/data.tar.gz -C ~/ data/ > $(HIDE) && echo " $(BACKUP_CREATED)" ; fi

clean:
	@sudo docker compose -f $(COMPOSE) down -v
	@sudo docker rm -f nginx wordpress mariadb > $(HIDE) 2>&1 || true

fclean: clean
	@sudo rm -rf ~/data
	@sudo docker image rm -f $(NAME)-nginx $(NAME)-wordpress $(NAME)-mariadb > $(HIDE) 2>&1 || true
	@sudo hostsed rm 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_REMOVED)"

remove: down fclean
	@echo "\nPreparing to start with a clean state..."
	@sudo docker stop $$(sudo docker ps -qa) > $(HIDE) 2>&1 || true
	@sudo docker rm $$(sudo docker ps -qa) > $(HIDE) 2>&1 || true
	@sudo docker rmi -f $$(sudo docker images -qa) > $(HIDE) 2>&1 || true
	@sudo docker volume rm $$(sudo docker volume ls -q) > $(HIDE) 2>&1 || true
	@sudo docker network rm $$(sudo docker network ls -q) > $(HIDE) 2>&1 || true

status:
	@clear
	@echo "\n--- CONTAINERS ---\n"; sudo docker ps -a
	@echo "\n--- IMAGES ---\n"; sudo docker image ls
	@echo "\n--- VOLUMES ---\n"; sudo docker volume ls
	@echo "\n--- NETWORKS ---\n"; sudo docker network ls --filter "name=$(NAME)_all"
	@echo ""

re: fclean all

create_dirs:
	@sudo mkdir -p ~/data/database ~/data/wordpress_files $(DATA_DIR)/database $(DATA_DIR)/wordpress_files

restore:
	@if [ -f ~/data.tar.gz ]; then sudo tar -xzvf ~/data.tar.gz -C ~/ > $(HIDE) && echo " $(BACKUP_RESTORED)" ; fi

HOST_ADDED          = $(CYAN)[INFO] Host entry added successfully$(RESET)
BUILD_INTERRUPTED   = $(YELLOW)[WARNING] Docker build interrupted$(RESET)
CONTAINERS_STARTED  = $(GREEN)[SUCCESS] Containers started successfully$(RESET)
CONTAINERS_STOPPED  = $(YELLOW)[INFO] Containers stopped$(RESET)
BACKUP_CREATED      = $(GREEN)[SUCCESS] Backup created successfully$(RESET)
BACKUP_RESTORED     = $(CYAN)[INFO] Backup restored successfully$(RESET)
HOST_REMOVED        = $(CYAN)[INFO] Host entry removed successfully$(RESET)

RED         = \033[1;31m
GREEN       = \033[1;32m
YELLOW      = \033[1;33m
CYAN        = \033[1;36m
RESET       = \033[0m

.PHONY: all sudo_check up down clean fclean remove status re create_dirs backup restore


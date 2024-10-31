NAME        = inception
SRCS        = ./srcs
COMPOSE     = $(SRCS)/docker-compose.yml
HOST_URL    = jmigoya-.42.fr

all: $(NAME)

$(NAME): up
	sudo

up: create_dir
	@mkdir -p ~/data/database
	@mkdir -p ~/data/wordpress_files
	@sudo mkdir -p /home/jmigoya-/data/database
	@sudo mkdir -p /home/jmigoya-/data/wordpress_files
	@sudo hostsed add 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_ADDED)"
	@sudo docker compose -p $(NAME) -f $(COMPOSE) up --build || (echo " $(BUILD_FAILED)" && exit 1)
	@echo " $(CONTAINERS_STARTED)"

down:
	@docker compose -p $(NAME) down
	@echo " $(CONTAINERS_STOPPED)"

# Creates a backup of the data folder in the home directory
backup:
	@if [ -d ~/data ]; then sudo tar -czvf ~/data.tar.gz -C ~/ data/ > $(HIDE) && echo " $(BACKUP_CREATED)" ; fi

# Stops the containers, removes the volumes and removes the containers
clean:
	@docker compose -f $(COMPOSE) down -v
	@if [ -n "$$(docker ps -a --filter "name=nginx" -q)" ]; then docker rm -f nginx > $(HIDE) && echo " $(NGINX_REMOVED)" ; fi
	@if [ -n "$$(docker ps -a --filter "name=wordpress" -q)" ]; then docker rm -f wordpress > $(HIDE) && echo " $(WORDPRESS_REMOVED)" ; fi
	@if [ -n "$$(docker ps -a --filter "name=mariadb" -q)" ]; then docker rm -f mariadb > $(HIDE) && echo " $(MARIADB_REMOVED)" ; fi

# Backs up the data and removes the containers, images, and the host URL from the host file
fclean: clean backup
	@sudo rm -rf ~/data
	@sudo rm -rf /home/jmigoya-/data/wordpress_files
	@if [ -n "$$(docker image ls $(NAME)-nginx -q)" ]; then docker image rm -f $(NAME)-nginx > $(HIDE) && echo " $(NGINX_IMAGE_REMOVED)" ; fi
	@if [ -n "$$(docker image ls $(NAME)-wordpress -q)" ]; then docker image rm -f $(NAME)-wordpress > $(HIDE) && echo " $(WORDPRESS_IMAGE_REMOVED)" ; fi
	@if [ -n "$$(docker image ls $(NAME)-mariadb -q)" ]; then docker image rm -f $(NAME)-mariadb > $(HIDE) && echo " $(MARIADB_IMAGE_REMOVED)" ; fi
	@sudo hostsed rm 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_REMOVED)"

status:
	@clear
	@echo "\nCONTAINERS\n"
	@docker ps -a
	@echo "\nIMAGES\n"
	@docker image ls
	@echo "\nVOLUMES\n"
	@docker volume ls
	@echo "\nNETWORKS\n"
	@docker network ls --filter "name=$(NAME)_all"
	@echo ""

# Removes all containers, images, volumes, and networks to start with a clean state
prepare:
	@echo "\nPreparing to start with a clean state..."
	@echo "\nStopping all containers...\n"
	@if [ -n "$$(docker ps -qa)" ]; then docker stop $$(docker ps -qa) ;	fi
	@echo "\nRemoving all containers...\n"
	@if [ -n "$$(docker ps -qa)" ]; then docker rm $$(docker ps -qa) ; fi
	@echo "\nRemoving all images...\n"
	@if [ -n "$$(docker images -qa)" ]; then docker rmi -f $$(docker images -qa) ; fi
	@echo "\nRemoving all volumes...\n"
	@if [ -n "$$(docker volume ls -q)" ]; then docker volume rm $$(docker volume ls -q) ; fi
	@echo "\nRemoving all networks...\n"
	@if [ -n "$$(docker network ls -q) " ]; then docker network rm $$(docker network ls -q) 2> /dev/null || true ; fi 
	@echo ""

re: fclean all

HIDE        = /dev/null 2>&1

RED         = \033[0;31m
GREEN       = \033[0;32m
RESET       = \033[0m

HOST_ADDED          = $(GREEN)Host added$(RESET)
BUILD_FAILED        = $(RED)Build failed$(RESET)
CONTAINERS_STARTED  = $(GREEN)Containers started$(RESET)
CONTAINERS_STOPPED  = $(GREEN)Containers stopped$(RESET)
BACKUP_CREATED      = $(GREEN)Backup created$(RESET)
NGINX_REMOVED       = $(GREEN)Nginx container removed$(RESET)
WORDPRESS_REMOVED   = $(GREEN)WordPress container removed$(RESET)
MARIADB_REMOVED     = $(GREEN)MariaDB container removed$(RESET)
NGINX_IMAGE_REMOVED = $(GREEN)Nginx image removed$(RESET)
WORDPRESS_IMAGE_REMOVED = $(GREEN)WordPress image removed$(RESET)
MARIADB_IMAGE_REMOVED = $(GREEN)MariaDB image removed$(RESET)
HOST_REMOVED        = $(GREEN)Host removed$(RESET)

.PHONY: all up down create_dir clean fclean status backup prepare re

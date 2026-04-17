SRCS=./srcs
COMPOSE=docker-compose.yml

start :
	docker compose -f $(COMPOSE) up --build
build :
	docker compose -f $(COMPOSE) build

down : 
	docker compose -f $(COMPOSE) down -v

restart : down start

up : local
	docker compose -f $(COMPOSE) up


clean :
	docker compose -f $(COMPOSE) down --rmi all --volumes --remove-orphans
prune : clean
	docker system prune -fa

test_crs:
	bash test_tools/test_modsec.sh

tls_gen:
	bash srcs/backend/vault/tools/vault-tls-gen.sh

local:
	mkdir -p ./srcs/frontend/build
	mkdir -p ./srcs/frontend/data
	mkdir -p ~/data/vault
	mkdir -p ~/data/postgresql
	mkdir -p ~/data/redis/data
	mkdir -p ~/data/postgresql/vault_agent
	mkdir -p ./srcs/frontend/public/field
	cp -r ~/sgoinfre/TRANSCENDANCE/data ~/
	cp ~/sgoinfre/TRANSCENDANCE/env .env
	cp ~/sgoinfre/TRANSCENDANCE/secret/postgres/secret_id ~/data/postgresql/vault_agent/secret_id
	cp ~/sgoinfre/TRANSCENDANCE/secret/service_user/secret_id ~/data/secrets/user/secret_id
	cp ~/sgoinfre/TRANSCENDANCE/secret/service_chat/secret_id ~/data/secrets/chat/secret_id             
	cp ~/sgoinfre/TRANSCENDANCE/secret/service_friends/secret_id ~/data/secrets/friends/secret_id 
	cp ~/sgoinfre/TRANSCENDANCE/secret/service_game/secret_id ~/data/secrets/game/secret_id
	cp ~/sgoinfre/TRANSCENDANCE/env.hdr ./srcs/frontend/public/env.hdr
	cp ~/sgoinfre/TRANSCENDANCE/strucLocker.glb srcs/frontend/public/lockerRoom/strucLocker.glb
	cp ~/sgoinfre/TRANSCENDANCE/strucPool.glb srcs/frontend/public/pool/strucPool.glb
	cp ~/sgoinfre/TRANSCENDANCE/strucField.glb srcs/frontend/public/field/strucField.glb


vault_start: local
	docker compose -f vault/docker-compose.yml up --build -d
vault_down:
	docker compose -f vault/docker-compose.yml down -v
vault_clean:
	docker compose -f vault/docker-compose.yml down --rmi all --volumes --remove-orphans
vault_prune: vault_clean
	docker system prune -fa


friends:
	docker compose -f srcs/docker-compose.yml up service-friends --build
postgresql:
	docker compose -f srcs/docker-compose.yml up postgreSQL --build
chat:
	docker compose -f srcs/docker-compose.yml up service-chat --build

game:
	docker compose -f srcs/docker-compose.yml up service-game --build
proxy:
	docker compose -f srcs/docker-compose.yml up proxy --build
.PHONY: start down restart up clean prune


# vault read -tls-skip-verify auth/approle/role/postgres-role/role-id
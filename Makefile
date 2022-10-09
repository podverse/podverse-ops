

ifeq ($(UNAME),Darwin)
	SHELL := /opt/local/bin/bash
	OS_X  := true
else ifneq (,$(wildcard /etc/redhat-release))
	RHEL := true
else
	OS_DEB  := true
	SHELL := /bin/bash
endif

say_hello:
	@echo "Hello World"

init_project:
	@echo "doing the work"

local_init_conf:
	cp ./config/podverse-api-local.env.example ./config/podverse-api-local.env
	cp ./config/podverse-db-local.env.example ./config/podverse-db-local.env
	cp ./config/podverse-web-local.env.example ./config/podverse-web-local.env
local_validate_init:
# https://stackoverflow.com/questions/5553352/how-do-i-check-if-file-exists-in-makefile-so-i-can-delete-it

# config/podverse-api-local.env
ifeq ("$(wildcard ./config/podverse-api-local.env)","")
	@echo "Missing: config/podverse-api-local.env"
endif

# config/podverse-db-local.env
ifeq ("$(wildcard ./config/podverse-db-local.env)","")
	@echo "Missing: config/podverse-db-local.env"
endif
# config/podverse-web-local.env
ifeq ("$(wildcard ./config/podverse-web-local.env)","")
	@echo "Missing: config/podverse-web-local.env"
endif
	@echo "Check complete"


local_up_db: 
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_db -d

local_up_manticore_server:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_manticore -d

local_manticore_indexes_init:
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_media_ref --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_playlist --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_podcast --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_01 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_02 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_03 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_04 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_05 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_06 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_07 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_08 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_09 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_10 --verbose

local_manticore_indexes_rotate:
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_author --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_media_ref --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_playlist --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_podcast --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_01 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_02 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_03 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_04 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_05 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_06 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_07 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_08 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_09 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_10 --rotate --verbose;

local_up_api:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_api -d

local_up_web:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_web -d

local_down_docker_compose:
	docker-compose -f docker-compose/local/docker-compose.yml down

.PHONY: local_up local_up_db local_up_manticore_server local_up_api local_up_web
local_up: local_up_db local_up_manticore_server local_up_api local_up_web


.PHONY: local_down local_down_docker_compose
local_down: local_down_docker_compose

.PHONY: local_refresh local_down local_up
local_refresh: local_down local_up



stage_clean_manticore:
	@echo "Cleaning Manticore"
	rm -rf ./manticore/data

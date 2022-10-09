

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


local_up_bg0:
	docker-compose -f docker-compose/local/docker-compose.yml up -d
local_up_fg0:
	docker-compose -f docker-compose/local/docker-compose.yml up
local_up_db_bg: 
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_db -d

local_up_db_fg: 
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_db

local_up_manticore_bg:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_db -d

local_up_api_bg:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_api -d

local_up_web_bg:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_web -d

stage_clean_manticore:
	@echo "Cleaning Manticore"
	rm -rf ./manticore/data

local_down_docker_compose:
	docker-compose -f docker-compose/local/docker-compose.yml down

.PHONY: local_up local_up_db_bg local_up_manticore_bg local_up_api_bg local_up_web_bg
local_up: local_up_db_bg local_up_manticore_bg local_up_api_bg local_up_web_bg

.PHONY: local_down local_down_bg0
local_down: local_down_docker_compose

.PHONY: local_refresh_fg local_down local_up_fg0
local_refresh_fg: local_down local_up_fg0

.PHONY: local_refresh_bg local_down local_up_fg0
local_refresh_bg: local_down local_up_bg0

.PHONY: local_refresh local_down local_up_fg0
local_refresh: local_down local_up_bg0 
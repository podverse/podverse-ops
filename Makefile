

ifeq ($(UNAME),Darwin)
	SHELL := /opt/local/bin/bash
	OS_X  := true
else ifneq (,$(wildcard /etc/redhat-release))
	RHEL := true
else
	OS_DEB  := true
	SHELL := /bin/bash
endif

.PHONY: say_hello
say_hello:
	@echo "Hello Podverse"

.PHONY: local_validate_init
local_validate_init: config/podverse-api-local.env config/podverse-db-local.env

config/podverse-api-local.env:
	@echo "Missing: $@"
	@echo "Copying from example file"
	cp ./$@.example ./$@

config/podverse-db-local.env:
	@echo "Missing: $@"
	@echo "Copying from example file"
	cp ./$@.example ./$@

.PHONY: local_nginx_proxy
local_nginx_proxy:
	@echo 'Generate new cert'
	test -d proxy/local/certs || mkdir -p proxy/local/certs
	cd proxy/local/certs && openssl genrsa -out podverse-server.key 4096
	cd proxy/local/certs && openssl rsa -in podverse-server.key -out podverse-server.key.insecure
	cd proxy/local/certs && openssl req -new -sha256 -key podverse-server.key -subj "/C=US/ST=Jefferson/L=Grand/O=EXA/OU=MPL/CN=podverse.local" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:podverse.local,DNS:www.podverse.local,DNS:api.podverse.local")) -out podverse-server.csr
	cd proxy/local/certs && openssl x509 -req -days 365 -in podverse-server.csr -signkey podverse-server.key -out podverse-server.crt

.PHONY: local_up_db
local_up_db:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_db -d

.PHONY: local_down
local_down:
	docker-compose -f docker-compose/local/docker-compose.yml down

proxy/local/certs:
	mkdir -p $@

proxy/local/certs/podverse-server.key:
	openssl genrsa -out $@ 4096

proxy/local/certs/podverse-server.key.insecure: proxy/local/certs/podverse-server.key
	openssl rsa -in $< -out $@

proxy/local/certs/podverse-server.csr: proxy/local/certs/podverse-server.key
	openssl req -new -sha256 -key $< -subj "/C=US/ST=Jefferson/L=Grand/O=Podverse/OU=Inra/CN=podverse.local" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:podverse.local,DNS:www.podverse.local,DNS:api.podverse.local")) -out $@

proxy/local/certs/podverse-server.crt: proxy/local/certs/podverse-server.csr
	openssl x509 -req -days 365 -in $< -signkey proxy/local/certs/podverse-server.key -out $@

.PHONY: local_nginx_proxy_cert
local_nginx_proxy_cert: proxy/local/certs proxy/local/certs/podverse-server.key proxy/local/certs/podverse-server.key.insecure proxy/local/certs/podverse-server.csr proxy/local/certs/podverse-server.crt
	@echo 'Generate new cert'

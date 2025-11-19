ifeq ($(UNAME),Darwin)
	SHELL := /opt/local/bin/bash
	OS_X  := true
else ifneq (,$(wildcard /etc/redhat-release))
	RHEL := true
else
	OS_DEB  := true
	SHELL := /bin/bash
endif

include Makefile.local
include Makefile.alpha
include Makefile.sandbox
include Makefile.test
include Makefile.certs

.PHONY: say_hello
say_hello:
	@echo "Hello Podverse"

.PHONY: prune_images
prune_images:
	docker image prune -a -f

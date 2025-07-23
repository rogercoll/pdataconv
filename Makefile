# From where to resolve the containers (e.g. "otel/weaver").
WEAVER_CONTAINER_REPOSITORY=docker.io
# Versioned, non-qualified references to containers used in this Makefile.
# These are parsed from dependencies.Dockerfile so dependabot will autoupdate
# the versions of docker files we use.
VERSIONED_WEAVER_CONTAINER_NO_REPO=$(shell cat dependencies.Dockerfile | awk '$$4=="weaver" {print $$2}')
# Versioned, non-qualified references to containers used in this Makefile.
WEAVER_CONTAINER=$(WEAVER_CONTAINER_REPOSITORY)/$(VERSIONED_WEAVER_CONTAINER_NO_REPO)

# Determine OS & Arch for specific OS only tools on Unix based systems
OS := $(shell uname | tr '[:upper:]' '[:lower:]')
ifeq ($(OS),darwin)
	SED ?= gsed
else
	SED ?= sed
endif

# Next - we want to run docker as our local file user, so generated code is not
# owned by root, and we don't give unecessary access.
#
# Determine if "docker" is actually podman
DOCKER_VERSION_OUTPUT := $(shell docker --version 2>&1)
DOCKER_IS_PODMAN := $(shell echo $(DOCKER_VERSION_OUTPUT) | grep -c podman)
ifeq ($(DOCKER_IS_PODMAN),0)
    DOCKER_COMMAND := docker
else
    DOCKER_COMMAND := podman
endif
DOCKER_RUN=$(DOCKER_COMMAND) run
DOCKER_USER=$(shell id -u):$(shell id -g)
DOCKER_USER_IS_HOST_USER_ARG=-u $(DOCKER_USER)
ifeq ($(DOCKER_COMMAND),podman)
 # On podman, additional arguments are needed to make "-u" work
 # correctly with the host user ID and host group ID.
 #
 #      Error: OCI runtime error: crun: setgroups: Invalid argument
 DOCKER_USER_IS_HOST_USER_ARG=--userns=keep-id -u $(DOCKER_USER)
endif


.PHONY: generate-example
generate-example:
	mkdir -p internal/metadata
	$(DOCKER_RUN) --rm \
		$(DOCKER_USER_IS_HOST_USER_ARG) \
		--mount 'type=bind,source=$(PWD)/semconv,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/internal/templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/internal/metadata,target=/home/weaver/target' \
		${WEAVER_CONTAINER} registry generate \
		--registry=/home/weaver/source \
		--future \
		metadata \
		/home/weaver/target
	cd internal/metadata; gofmt -w -s ./; go mod tidy;

# feature/docker.inc.mk
FEATURE_DOCKER := Y

ifeq ($(HOST_OS),Darwin)
DOCKER_DAEMON := com.[d]ocker.backend
endif

ifeq ($(HOST_OS),Linux)
DOCKER_DAEMON := [d]ockerd
endif

DOCKER_RUNNING := $(shell ps ax | grep -qs $(DOCKER_DAEMON) && echo Y || echo N)
$(call debug2,DOCKER_RUNNING is $(DOCKER_RUNNING))

.PHONY: ddr dds start-docker
ddr dds start-docker: ## Start (Run) the docker daemon, if not already started (Currently running: $(DOCKER_RUNNING))
ifeq ($(DOCKER_RUNNING)-$(HOST_OS),N-Darwin)
	@open -a Docker --background
	sleep 5
else
	$(call debug,Docker is running? $(DOCKER_RUNNING))
ifeq ($(DOCKER_RUNNING),N)
	$(error Please start Docker and try again)
endif
endif # N-Darwin

.PHONY: down
down: ## Stop the docker containers, remove networks
	docker compose down $($@_ARGS)

.PHONY: logs
logs: ddr docker-compose.yml ## Show container logs for the $(CONTAINER_NAME) container
	docker logs $(CONTAINER_NAME) $($@_ARGS)

.PHONY: rb rebuild
.SECONDEXPANSION:
rb rebuild: docker-compose.yml $$(CERTS_TARGET) ## Recreate and restart the docker containers
	docker compose up -d --force-recreate

.PHONY: rerun restart rr
.SECONDEXPANSION:
rerun restart rr: docker-compose.yml $$(CERTS_TARGET) ## (Re)start the docker containers
	docker compose restart $($@_ARGS)

# @FIXME: This seems to restart sometimes, even if already running.  Not sure why.
.PHONY: run start up
.SECONDEXPANSION:
run start up: ddr docker-compose.yml $$(CERTS_TARGET) ## Run the docker containers, if already stopped.  Don't restart if running.
	docker compose up -d $($@_ARGS)

.PHONY: run-fg
.SECONDEXPANSION:
run-fg: ddr stop $$(CERTS_TARGET) ## Run the docker containers in the foreground.  Stops any running containers first.
	docker compose up $($@_ARGS)

.PHONY: ssh
ssh: run ## SSH into the $(CONTAINER_NAME) container
	docker exec -t -i $(CONTAINER_NAME) /bin/bash
# @FIXME: Support images that don't have bash
#	docker exec -t -i $(CONTAINER_NAME) /bin/sh

.PHONY: status st ls
status st ls: ## Show (all) container status
	docker compose ls $($@_ARGS)

.PHONY: stop
stop: ## Stop the docker containers
	docker compose stop $($@_ARGS)

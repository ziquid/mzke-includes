# feature/image.inc.mk
FEATURE_IMAGE := Y

DOCKERFILE ?= Dockerfile

.PHONY: bpa build
bpa build: $(DOCKERFILE) ddr ## Build and Push All custom Docker image(s) built by this app
ifeq ($(IS_PROD),Y)
	$(eval IMAGE_BUILD_PUSH := --push)
	$(eval IMAGE_BUILD_PLATFORMS := --platform linux/amd64,linux/arm64)
else
	$(eval IMAGE_BUILD_PUSH := --load)
	$(info Cowardly refusing to push a non-prod branch to container registry)
endif
	docker buildx use mybuilder
	docker buildx build -f $(DOCKERFILE) $(IMAGE_BUILD_PLATFORMS) $(IMAGE_BUILD_PUSH) -t $(IMAGE) .

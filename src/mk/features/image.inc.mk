# feature/image.inc.mk

.PHONY: bpa build
bpa build: Dockerfile ddr ## Build and Push All custom Docker image(s) built by this app
ifeq ($(IS_PROD),Y)
	$(eval IMAGE_BUILD_PUSH := --push)
else
	$(eval IMAGE_BUILD_PUSH := --load)
	$(info Cowardly refusing to push a non-prod branch to container registry)
endif
	docker buildx use mybuilder
	docker buildx build --platform linux/amd64,linux/arm64 $(IMAGE_BUILD_PUSH) -t $(IMAGE) .

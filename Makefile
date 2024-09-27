.PHONY: default
default: build

DOCKER_IMAGE ?= $(strip $(notdir $(shell git rev-parse --show-toplevel)))

# get build date
BUILD_DATE = $(strip $(shell date -u +'%Y-%m-%dT%H:%M:%SZ'))
# get the latest commit
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))
# get remote origin url
GIT_URL = $(strip $(shell git config --get remote.origin.url))

VERSION = main

.PHONY: build
build: docker-build
	@echo Successfully built: $(DOCKER_IMAGE):$(VERSION)
	@echo

.PHONY: docker-build
docker-build: docker-build-arm64 docker-build-amd64

.PHONY: docker-build-arm64
docker-build-arm64:
	docker buildx build \
	--platform linux/arm64 \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--build-arg VCS_REF=$(GIT_COMMIT) \
	--build-arg VCS_URL=$(GIT_URL) \
	--load \
	-t $(DOCKER_IMAGE)-arm64:$(VERSION) .

.PHONY: docker-build-amd64
docker-build-amd64:
	docker buildx build \
	--platform linux/amd64 \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--build-arg VCS_REF=$(GIT_COMMIT) \
	--build-arg VCS_URL=$(GIT_URL) \
	--load \
	-t $(DOCKER_IMAGE)-amd64:$(VERSION) .

.PHONY: push
push: push-arm64 push-amd64 create-manifest
	docker manifest push wolffaxn/$(DOCKER_IMAGE):main

.PHONY: push-arm64
push-arm64:
	docker tag $(DOCKER_IMAGE)-arm64:$(VERSION) wolffaxn/$(DOCKER_IMAGE)-arm64:main
	docker push wolffaxn/$(DOCKER_IMAGE)-arm64:main

.PHONY: push-amd64
push-amd64:
	docker tag $(DOCKER_IMAGE)-amd64:$(VERSION) wolffaxn/$(DOCKER_IMAGE)-amd64:main
	docker push wolffaxn/$(DOCKER_IMAGE)-amd64:main

.PHONY: create-manifest
create-manifest:
	docker manifest create wolffaxn/$(DOCKER_IMAGE):main \
	wolffaxn/$(DOCKER_IMAGE)-arm64:main \
	wolffaxn/$(DOCKER_IMAGE)-amd64:main

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
docker-build:
	docker build \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--build-arg VCS_REF=$(GIT_COMMIT) \
	--build-arg VCS_URL=$(GIT_URL) \
	-t $(DOCKER_IMAGE):$(VERSION) .

.PHONY: push
push:
	docker tag $(DOCKER_IMAGE):$(VERSION) wolffaxn/$(DOCKER_IMAGE):main
	docker push wolffaxn/$(DOCKER_IMAGE):main

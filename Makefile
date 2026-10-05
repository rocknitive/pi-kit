IMAGE ?= ghcr.io/rocknitive/pi-kit-image:latest
KIT ?= .
PI_VERSION ?= latest
OPENSPEC_VERSION ?= latest

.PHONY: build validate run

build:
	docker build --pull \
		--build-arg PI_VERSION=$(PI_VERSION) \
		--build-arg OPENSPEC_VERSION=$(OPENSPEC_VERSION) \
		-t $(IMAGE) .

validate:
	sbx kit validate $(KIT)

run: build validate
	sbx run --kit $(KIT) pi

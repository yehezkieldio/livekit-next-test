DOCKER_IMAGE_NAME := bun-livekit-next
DOCKER_BUILD_ARGS := --build-arg user=elizielx --build-arg uid=1000

up:
	docker-compose up -d
down:
	docker-compose down
build:
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_IMAGE_NAME) .
stop:
	docker stop $(DOCKER_IMAGE_NAME)
	docker rm $(DOCKER_IMAGE_NAME)

.PHONY: up down build
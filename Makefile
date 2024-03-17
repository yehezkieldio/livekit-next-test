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
run:
	docker run -d --name $(DOCKER_IMAGE_NAME) -p 3000:3000 $(DOCKER_IMAGE_NAME)
logs:
	docker logs $(DOCKER_IMAGE_NAME)
run-in:
	docker exec -it $(DOCKER_IMAGE_NAME) /bin/bash

.PHONY: up down build

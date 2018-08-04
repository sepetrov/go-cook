.PHONY: \
	build \
	up \
	exec \
	clean

build:
	docker build -t loom .
up:
	docker-compose up -d
exec:
	docker exec -it loom /bin/bash
clean:
	docker-compose rm -fsv
	docker rmi loom
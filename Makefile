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
	docker exec -it loom /bin/sh
clean:
	docker-compose rm -fsv
	docker rmi loom
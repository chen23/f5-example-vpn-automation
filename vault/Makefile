# from: https://raw.githubusercontent.com/vinnie357/demo-gcp-tf/master/vault-dev/Makefile
#https://github.com/hashicorp/docker-vault
.PHONY: vault test

export DIR = $(shell pwd)
export WORK_DIR = $(shell dirname ${DIR})

export CONTAINER_IMAGE = 'vault'
export VAULT_PORT ='8200'
export TOKEN='root'

vault:
	@# docker run --cap-add=IPC_LOCK -d --name=dev-vault vault
	@# docker run --cap-add=IPC_LOCK -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:1234' vault
	@#vault dev
	@docker run --rm -d \
	--cap-add=IPC_LOCK \
	--name=dev-vault \
	-p ${VAULT_PORT}:${VAULT_PORT} \
	-e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:${VAULT_PORT}' \
	-e 'VAULT_DEV_ROOT_TOKEN_ID=${TOKEN}' \
	${CONTAINER_IMAGE}

destroy:
	@#https://docs.docker.com/engine/reference/commandline/rmi/
	@#docker destroy
	@docker rm --force dev-vault

logs:
	@#https://docs.docker.com/engine/reference/commandline/logs/
	@# show running container logs
	@docker logs dev-vault

test: test1 test2

test1:
	@#test for docker
	@docker --version
test2:
	@# test vault
	@curl -v http://localhost:${VAULT_PORT}

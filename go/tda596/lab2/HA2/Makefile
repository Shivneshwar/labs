docker_create_build_name="ha2_chord_create"
docker_join_build_name="ha2_chord_join"

####
# Add ons needed, but not related to the code itself

sftp_c:
	docker run --rm -d -p $(p):22 \
	-v ${PWD}/keys/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
	-v ${PWD}/keys/id_rsa:/etc/ssh/ssh_host_rsa_key:ro \
	atmoz/sftp foo::1001::resources

sftp_keys:
	ssh-keygen -t rsa -b 4096 -f ${PWD}/keys/id_rsa

file_encryption_keys:
	openssl genrsa -out ./keys/encryption-priv.pem
	openssl rsa -in ./keys/encryption-priv.pem -pubout -out ./keys/encryption-pub.pem
####


####
# Generic commands for running via docker
build_join:
	docker build -t $(docker_join_build_name) -f Dockerfile.join .


####
# Commands for setting up multiple nodes in a single server, for instance in the cloud
# First node in the chord ring, does not need to be run, if chord ring has been initialized on another server
create:
	docker build -t $(docker_create_build_name) -f Dockerfile.create .
	$(MAKE) sftp_c p=$(sp)
	docker run -dit --rm --publish $(p):$(p) -e ADDRESS=$(a) -e PORT=$(p) -e SSH_PORT=$(sp) $(docker_create_build_name)

# Runs without detach mode, so that it can be used interactively
run_client:
	$(MAKE) sftp_c p=$(sp)
	docker run -it --rm --publish $(p):$(p)  -e ADDRESS=$(a) -e PORT=$(p) -e SSH_PORT=$(sp) -e JOIN_ADDRESS=$(ja) -e JOIN_PORT=$(jp) $(docker_join_build_name)





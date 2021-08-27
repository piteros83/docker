# BASICS
docker container run -d -p 3306:3306 --name db -e MYSQL_RANDOM_ROOT_PASSWORD=yes mysql
docker container logs db
docker container run -d --name webserver -p 8080:80 httpd
docker ps / docker container ps
docker container run -d --name proxy -p 80:80 nginx (ports is always in HOST:CONTAINER format)
curl localhost
curl localhost:8080
docker container stop [TAB] IDs
docker container ls -a
docker container rm [IDs]
docker image ls

# SIMPLE MONTORING:
docker container top [CONTAINER]
docker container inspect [CONTAINER]
docker container stats [CONTAINER] or all without parameters or -all

# SHELL IN CONTAINERS:
docker container run -it --name proxy nginx bash
docker container run -it --name ubuntu ubuntu
docker container start -ai ubuntu
docker container exec -it mysql bash

docker pull apline 
docker image ls
docker container run -it alpine sh

#NETWORKING:
docker container port webhost
docker container inspect --format '{{ .NetworksSettings.IPAddress ]]' webhost
docker network ls
docker network inspect [name of net]
docker network create --driver
docker network connect / disconnect
docker network create my_app_net
docker container run -d --name new_nginx --network my_app_net nginx

#DNS:
docker container run -d --name my_nginx --network my_app_net nginx
docker container exec -it my_nginx ping new_nginx

#ASSIGNMENT: CLI APP TESTING
docker container run --rm -it centos:7 bash
yum update curl
#shift+D / new terminal window
docker container run --rm -it ubuntu:14.04 bash
apt-get update && apt-get install -y curl

#ASSIGNMENT: DNS ROUND ROBIN TEST
docker network create dude (create vnetwork dude)
docker container run -d --net dude --net-alias search elasticserach:2
docker container run -d --net dude --net-alias search elasticserach:2
docker container run --rm --net dude alpine nslookup search
docker container run --rm --net dude centos curl -s search:9200

#IMAGES:
docker pull nginx:1.11
docker image ls 
docker history nginx:latest (old command)
docker history mysql
docker image inspect  nginx 

docker image tag --help
docker image tag nginx costamcostam/nginx
docker login 

docker bulid -f some-dockerfile (edit file)
docker image build  -t customnginx .

#ASSIGNMENT: BUILD YOUR OWN IMAGE
cd dockerfile-assignment-1
vim DockerFile ->
	FROM node:6-alipne
	EXPOSE 3000
	RUN apk add --update tini
	RUN mkdir -p /usr/src/app	
	WORKDIR /usr/src/app
	COPY package.json package.json
	RUN nmp install && nmp cache clean
	COPY . .
	CMD [ "tini", "--", "node", "./bin/www" ]
docker build -t testnode .
docker container run --rm -p 80:3000 testnode
docker tag testnode bretfisher/testing-node
docker push bretfisher/testing-node
docker image rm bretfisher/testing-node
docker container run --rm -p 80:3000 bretfisher/testing-node

# LIFETIME AND PERSISTENT DATA:
#/var/lib/docker/volumes/..../_data
docker pull mysql
docker image inspect mysql
docker container run -d --name mysql -e MYSQL_RANDOM_ROOT_PASSWORD=True mysql
docker container ls
docker container inspect mysql
docker volume ls
docker volume inspect ...
docker container run -d --name mysql2 -e MYSQL_RANDOM_ROOT_PASSWORD=True mysql
docker conterner stop mysql
docker conterner stop mysql2
docker contaner ls
docker volume ls
docker conterner rm mqsql mysql2
docker volume ls (volumes are still there)
docker container run -d --name mysql -e MYSQL_RANDOM_ROOT_PASSWORD=True -v mysql-db:/var/lib/mysql mysql
docker volume ls

docker volume create --help
#bind mounts can be specified only in container run:
#... run -v /Users/xxx/stuff:/path/container (linux)
#... run -v //c/Users/xxx/stuff:/path/container 

cd dockerfile-sample-2
docker container run -d --name nginx -p 80:8080 -v $(pwd):/usr/share/nginx/html nginx

# ASSIGNMENT NAMED VOLUME:
docker container run -d --name psql -v psql:/var/lib/postgresql/data postgres:9.6.1
docker container logs -f psql
docker contairne stop psql
docker container run -d --name psql2 -v psql:/var/lib/postgresql/data postgres:9.6.2
docker container ps -a
docker volume ls
docker container logs [ID]

# ASSIGNMENT BIND MOUNTS:
cd bindmounts-sample-1
docker container run -p 80:4000 -v $(pwd):/site bretfisher/jekyll-serve

# DOCKER COMPOSE:
docker-compose up    # setup volumes/networks and start all containers
docker-compose down  # stop all containers and remove cont/vol/net

cd compose-sample-2
docker-compose up
docker-compose --help
docker compose ps
docker compose top
docker-compose down

# ASSIGNMENT: WRITING A COMPOSE FILE:
cd compose-aasignment-2
docker-compose.yml
---------------------------------------------------------
	version: '2'
	
	services:
	  drupal:
	  image: drupal
	  ports:
	   - "8080:80"
	  volumes:
	   - drupal-modules:/var/www/html/modules
	   - drupal-profiles:/var/www/html/profiles
	   - drupal-sites:/var/www/html/sites
	   - drupal-themes:/var/www/html/themes
	  postgres:
	   image: postgres
	   environment:
		-POSTGRES_PASSWORD=mypasswd
	volumes:
	  drupal-modules:
	  drupal-profiles:
	  drupal-sites:
	  drupal-themes:
---------------------------------------------------------   
docker-compose down -v

docker-compose build (...up --build)
docker-compose down --rmi local (remove with image)

############################################################
# ASSIGNMENT: Build and Run Compose:
# compose from previous assignment
cd compose-assignment-2
#Dockerfile
---------------------------------------------------------
FROM drupal:8.2

RUN apt-get update && apt-get install -y[automatic YES] git \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/themes

RUN git clone --branch 8.x-3.x --single-branch --depth 1  https://git.drupal.org/project/bootstrap.git
	&& chown -R www-data:www-data bootstrap

WORKDIR /var/www/html/modules
------------------------------------------------------------

docker-compose.yml
---------------------------------------------------------
	version: '2'
	
	services:
	  drupal:
	  image: custom-drupal
	  build: .
	  ports:
	   - "8080:80"
	  volumes:
	   - drupal-modules:/var/www/html/modules
	   - drupal-profiles:/var/www/html/profiles
	   - drupal-sites:/var/www/html/sites
	   - drupal-themes:/var/www/html/themes
	  postgres:
	   image: postgres:9.6
	   environment:
		-POSTGRES_PASSWORD=mypasswd
	   volumes:
	    - drupal-data:/var/lib/postgresql/data
	volumes:
	  drupal-data:
	  drupal-modules:
	  drupal-profiles:
	  drupal-sites:
	  drupal-themes:
---------------------------------------------------------
docker-compose up

========================================================================
# SWARM:

docker info #(check if sworm is active)
docker swarm init
docker node ls
docker node --help
docker service --help
docker service create alpine ping 8.8.8.8
docker service ls
docker service ps [ID]
docker service update [ID] --replicas 3
docker service ls
docker service ps [ID]
docker update --help
docker service update
docker container rm -f [ID:1]
docker service ls x2

docker swarm init --advertise-addr 10.0.21.3
docker swarm join --token...
docker node update --role manager node2
docker node update --role manager node3
docker swarm join-token manager

docker service create --replicas 3 alpine ping 8.8.8.8
docker service ls
docker node ps node2
docker sevice ps sleepy_brown

docker wide bridge network for swarm (as VLAN)
docker create network  --driver overlay
docker network create --driver overlay mydrupal
docker service create --name plsql --network mydrupal -e POSTGRES_PASSWORD=mypass postgres
docker service ls
docker container logs plsql[TAB]
docker service create --name drupal --network mydrupal -p 80:80 drupal


PRIVATE DOCKER REGISTRY:
========================================================================
docker container run -d -p 5000:5000 -name registry registry
docker pull hello-world
docker tag hello-world 127.0.0.1:500/hello-world
docker image ls
docker image remove 127.0.0.1:500/hello-world
docker pull 127.0.0.1:500/hello-world
docker container kill regostry
docker container rm registry
========================================================================


DOCKER SECRETS:
========================================================================
docker secret create plsql_user plsql_user.txt
echo "mypass" | docker secret create plsql_pass -
docker secret ls
docker secret inspect plsql_user
docker service create --name plsql --secret plsql_user -secret plsql_pass -e POSTGRES_PASSWORD=/run/secrets/plsql_pass -e POSTGRES_USER_FILE=/run/secrets/plsql_user postgres
docker servcice ps plsql
docker exec -it plsql[TAB] bash
ls /run/secrets
cat plsql_user
docker service update --secret-rm 

secrets with stacks:
version 3.1

secrets with docker compose (locally):
docker-compose exec psql cat/run/secrets/psql_user

ASSIGNMENT Deploy swarm with secrets:
========================================================================

docker-compose.yml listing:
----------------------------------------
version: '3.1'

services:

	drupal:
		image: drupal:8.2
		ports:
		 - "8080:80"
		volumes:
		 - drupal-modules:/var/www/html/modules
		 - drupal-profiles:/var/www/html/profiles
		 - drupal-sites:/var/www/html/sites
		 - drupal-themes:/var/www/html/themes
		 
	postgres:
		image: postgres:9.6
		environment:
		  - POSTGRES_PASSWORD_FILE=/runsecrets/psql-pw
		secrets:
  		  - psql-pw
		volumes:
		  - drupal-data:/var/lib/postgresql/data

volumes:
	drupal-data:
	drupal-modules:
	drupal-profiles:
	drupal-sites:
	drupal-themes:
		  
secrets:
	psql-pw:
		external: true
---------------------------------------- 

echo "sadgfadsfg444" | docker secret create psql-pw - 
docker stack deploy -c docker-compose.yml drupal
docker stack ps drupal

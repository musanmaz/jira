# Dockerized Atlassian Jira

## Introduction
Run Jira Core, Jira Software, or Jira Service Desk in a Docker container.

"The best software teams ship early and often - Not many tools, one tool. Jira Software is built for every member of your software team to plan, track, and release great software." - [[Source](https://www.atlassian.com/software/jira)]

## Products, Versions, and Tags

| Product | Version                | Tags                     |
|---------|------------------------|--------------------------|
| [Jira Software](https://www.atlassian.com/software/jira) | 8.20.30 to 9.16.1 | 8.20.30, ..., 9.16.1 |

## You may also like

* [musanmaz/confluence](https://github.com/musanmaz/confluence): Create, organize, and discuss work with your team
* [musanmaz/bitbucket](https://github.com/musanmaz/bitbucket): Code, Manage, Collaborate
* [musanmaz/crowd](https://github.com/musanmaz/crowd): Identity management for web apps
* [development - running this image for development including a debugger](https://github.com/musanmaz/jira/tree/master/examples/debug)

## Setup

### Docker-Compose:
> Jira will be available at http://yourdockerhost

~~~~
$ curl -O https://raw.githubusercontent.com/musanmaz/jira/master/docker-compose.yml
$ docker-compose up -d
~~~~

### Docker-CLI:
> Jira will be available at http://yourdockerhost
> Data will be persisted inside docker volume `jiravolume`.

~~~~
docker run -d -p 80:8080 -v jiravolume:/var/atlassian/jira --name jira musanmaz/jira
~~~~

### Docker run

#### 1. Start Database
> This uses the postgres image. Data will be persisted inside docker volume `postgresvolume`.
> Note: You should change the password!
~~~~
docker network create jiranet
docker run --name postgres -d \
    --network jiranet \
    -v postgresvolume:/var/lib/postgresql \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_ENCODING=UNICODE' \
    -e 'POSTGRES_COLLATE=C' \
    -e 'POSTGRES_COLLATE_TYPE=C' \
    postgres:12.17-alpine
~~~~

#### 2. Start Jira
~~~~
docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  -p 80:8080 musanmaz/jira
~~~~

## Proxy Configuration

You can specify your proxy host and proxy port with the environment variables JIRA_PROXY_NAME and JIRA_PROXY_PORT. The value will be set inside the Atlassian server.xml at startup!

When you use HTTPS then you also have to include the environment variable JIRA_PROXY_SCHEME.

### Example
> This will set the values inside the server.xml in `/opt/jira/conf/server.xml` and build the image with the current Jira release

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

~~~~
docker run -d --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=myhost.example.com" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    musanmaz/jira
~~~~

## Database Setup for Official Database Images

1. Start a database server.
1. Create a database with the correct collate.
1. Start Jira.

Example with PostgreSQL:

First start the database server:

> Note: Change Password!

~~~~
docker network create jiranet
docker run --name postgres -d \
    --network jiranet \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:12.17
~~~~

> This is the official Postgres image.

Then create the database with the correct collate:

~~~~
docker run -it --rm \
    --network jiranet \
    postgres:12.17-alpine \
    sh -c 'exec createdb -E UNICODE -l C -T template0 jiradb -h postgres -p 5432 -U jira'
~~~~

> Password is `jellyfish`. Creates the database `jiradb` under user `jira` with the correct encoding and collation.

Then start Jira:
>  Start the Jira and link it to the postgres instance.

~~~~
docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish" \
	  -p 80:8080 musanmaz/jira
~~~~

## Demo Database Setup

> Note: It's not recommended to use a default initialized database for Jira in production! The default databases are all using a not recommended collation! Please use this for demo purposes only!

This is a demo "by foot" using the docker cli. In this example, we setup an empty PostgreSQL container. Then we connect and configure the Jira accordingly. Afterwards, the Jira container can always resume on the database.

Steps:

* Start Database container
* Start Jira

### PostgreSQL

Let's use a PostgreSQL image and set it up:

#### PostgreSQL - official image

~~~~
$ docker network create jiranet
$ docker run --name postgres -d \
    --network jiranet \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_USER=jiradb' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:12.17-alpine
~~~~

#### PostgreSQL - community image

~~~~
$ docker run --name postgres -d \
    --network jiranet \
    -e 'DB_USER=jiradb' \
    -e 'DB_PASS=jellyfish' \
    -e 'DB_NAME=jiradb' \
    sameersbn/postgresql:12-20200524
~~~~

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  -e "JIRA_DATABASE_URL=postgresql://jiradb@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish" \
	  -p 80:8080 musanmaz/jira
~~~~

### MySQL

Let's use a MySQL image and set it up:

#### MySQL - official image

~~~~
$ docker network create jiranet
$ docker run -d --name mysql \
    --network jiranet \
    -e 'MYSQL_ROOT_PASSWORD=verybigsecretrootpassword' \
    -e 'MYSQL_DATABASE=jiradb' \
    -e 'MYSQL_USER=jiradb' \
    -e 'MYSQL_PASSWORD=jellyfish' \
    mysql:5.7
~~~~

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_DATABASE_URL=mysql://jiradb@mysql/jiradb" \
    -e "JIRA_DB_PASSWORD=jellyfish"  \
    -p 80:8080 \
    musanmaz/jira
~~~~

### SQL Server

~~~~
docker run \
    -d \
    --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_DATABASE_URL=sqlserver://MySQLServerHost:1433;databaseName=MyDatabase" \
    -e "JIRA_DB_USER=jira-app" \
    -e "JIRA_DB_PASSWORD=***" \
    -p 8080:8080 \
    musanmaz/jira
~~~~

## Database Wait Feature

A Jira container can wait for the database container to start up. You have to specify the host and port of your database container and Jira will wait up to one minute for the database.

You can define the waiting parameters with the environment variables:

* `DOCKER_WAIT_HOST`: The host to poll Mandatory!
* `DOCKER_WAIT_PORT`: The port to poll Mandatory!
* `DOCKER_WAIT_TIMEOUT`: The timeout in seconds. Optional! Default: 60
* `DOCKER_WAIT_INTERVAL`: The time in seconds we should wait before polling the database again. Optional! Default: 5

Example waiting for a PostgreSQL database:

First start Jira:

~~~~
docker network create jiranet
docker run --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "DOCKER_WAIT_HOST=postgres" \
    -e "DOCKER_WAIT_PORT=5432" \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  -p 80:8080 musanmaz/jira
~~~~

> Waits at most 60 seconds for the database.

Start the database within 60 seconds:

~~~~
docker run --name postgres -d \
    --network jiranet \
    -v postgresvolume:/var/lib/postgresql \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_ENCODING=UNICODE' \
    -e 'POSTGRES_COLLATE=C' \
    -e 'POSTGRES_COLLATE_TYPE=C' \
    postgres:12.17-alpine
~~~~

# Build The Image

```
docker-compose build jira
```

If you want to build a specific release, just replace the version in .env and again run

```
docker-compose build jirqa
```

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

Just type:

~~~~
$ docker run -d --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=myhost.example.com" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    musanmaz/jira
~~~~

> Will set the values inside the server.xml in /opt/jira/conf/server.xml

# NGINX HTTP Proxy

This is an example on running Atlassian Jira behind NGINX with 2 Docker commands!

First start Jira:

~~~~
$ docker network create jiranet
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=192.168.99.100" \
    -e "JIRA_PROXY_PORT=80" \
    -e "JIRA_PROXY_SCHEME=http" \
    musanmaz/jira
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 80:80 \
    --network jiranet \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://jira:8080" \
    musanmaz/nginx
~~~~

> Jira will be available at http://192.168.99.100.

# NGINX HTTPS Proxy

This is an example on running Atlassian Jira behind NGINX-HTTPS with2 Docker commands!

Note: This is a self-signed certificate! Trusted certificates by letsencrypt are supported. Documentation can be found here: [musanmaz/nginx](https://github.com/musanmaz/nginx)

First start Jira:

~~~~
$ docker network create jiranet
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=192.168.99.100" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    musanmaz/jira
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 443:443 \
    --name nginx \
    --network jiranet \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://jira:8080" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=CrustyClown/OU=SpringfieldEntertainment/O=crusty.springfield.com/L=Springfield/C=US" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    musanmaz/nginx
~~~~

> Jira will be available at https://192.168.99.100.

## Configuration

### A Word About Memory Usage

Jira like any Java application needs a huge amount of memory. If you limit the memory usage by using the Docker --mem option make sure that you give enough memory. Otherwise, Jira will begin to restart randomly.

You should give at least 1-2GB more than the JVM maximum memory setting to your container.

Java JVM memory settings are applied by manipulating properties inside the `setenv.sh` file and this image can set those properties for you.

The correct properties from the Atlassian documentation are:
- `JVM_MINIMUM_MEMORY`
- `JVM_MAXIMUM_MEMORY`

The image will set those properties, if you precede the property name with `SETENV_`.

~~~~
docker run -d -p 80:8080 --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "SETENV_JVM_MINIMUM_MEMORY=2048m" \
    -e "SETENV_JVM_MAXIMUM_MEMORY=8192m" \
    musanmaz/jira
~~~~

### Jira Startup Plugin Purge

You can enable osgi plugin purge on startup and restarts. The image will merciless purge the direcories

* /var/atlassian/jira/plugins/.bundled-plugins
* /var/atlassian/jira/plugins/.osgi-plugins

This will help solving [corrupted plugin caches](https://confluence.atlassian.com/jirakb/troubleshooting-jira-startup-failed-error-394464512.html#TroubleshootingJIRAStartupFailedError-Cache). Make sure to [increasing the plugin timeout](https://confluence.atlassian.com/jirakb/troubleshooting-jira-startup-failed-error-394464512.html#TroubleshootingJIRAStartupFailedError-Time) because Jira will have to rebuild the whole cache at each startup.

This is controlled by the environment variable `JIRA_PURGE_PLUGINS_ONSTART`. Possible values:

* `true`: Purge will be done each time container is started or restarted.
* `false` (Default): No purge will be done.

Example:

~~~~
$ docker run -d -p 80:8080 -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PURGE_PLUGINS_ONSTART=true" \
    --name jira musanmaz/jira
~~~~

# Jira SSO With Crowd

You enable Single Sign On with Atlassian Crowd. What is crowd?

"Users can come from anywhere: Active Directory, LDAP, Crowd itself, or any mix thereof. Control permissions to all your applications in one place – Atlassian, Subversion, Google Apps, or your own apps." - [Atlassian Crowd](https://www.atlassian.com/software/crowd/overview)

This is controlled by the environment variable `JIRA_CROWD_SSO`. Possible values:

* `true`: Jira configuration will be set to Crowd SSO authentication class at every restart.
* `false`: Jira configuration will be set to Jira Authentication class at every restart.
* `ignore` (Default): Config will not be touched, current image setting will be taken.

You have to follow the manual for further settings inside Jira and Crowd: [Documentation](https://confluence.atlassian.com/crowd/integrating-crowd-with-atlassian-jira-192625.html)

Example:

~~~~
$ docker run -d -p 80:8080 -v jiravolume:/var/atlassian/jira \
    -e "JIRA_CROWD_SSO=true" \
    --name jira musanmaz/jira
~~~~

> SSO will be activated, you will need Crowd in order to authenticate.

## Custom Configuration

You can use your customized configuration, e.g. Tomcat's `server.xml`. This is necessary when you need to configure something inside Tomcat that cannot be achieved by this image's supported environment variables. I will give an example for `server.xml` any other configuration file works analogous.

1. First create your own valid `server.xml`.
1. Mount the file into the proper location inside the image. E.g. `/opt/jira/conf/server.xml`.
1. Start Jira

~~~~
docker run -d --name jira \
    -p 80:8080 \
    -v jiravolume:/var/atlassian/jira \
    -v $(pwd)/server.xml:/opt/jira/conf/server.xml \
    musanmaz/jira
~~~~

> Note: `server.xml` is located in the directory where the command is executed.

### Extending This Image

You can easily extend this image with your own tooling by following the example below:

~~~~
FROM musanmaz/jira

USER root

... Install your tooling ...

USER jira
CMD ["jira"]
~~~~
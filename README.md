# podverse-ops

Deployment scripts for the podverse ecosystem.

## Getting Started

### Local vs Stage vs Prod

To test the Docker containers locally, use the docker-compose.local.yml file.

For stage deployment, use the docker-compose.stage.yml file, and replace _local
in commands with _stage.

For prod deployment, use the docker-compose.prod.yml file, and replace _local
in commands with _prod.

#### Setup environment variables

Duplicate the config/podverse-web-local.example.env file, rename it to config/podverse-web-local.env, and update all of the environment variables to match what is needed for your environment.

Add your BitPay API key file to config/bitpay/api.key. Look in the config/bitpay/api.key.example for more info.

Add your Google API key file to config/google/jwt.keys.json. Look in the config/google/jwt.keys.json.example for more info.

### Create and start Nginx container

```
docker-compose -f docker-compose.stage.yml up -d podverse_nginx_proxy
```

#### Start a Postgres instance

```
docker-compose -f docker-compose.local.yml up -d podverse_db
```

#### Create and start the podverse_api and podverse_web containers

```
docker-compose -f docker-compose.local.yml up -d podverse_api podverse_web
```

#### Run the podverse_api application

```
docker exec -d podverse_api_local npm --prefix /tmp start
```

#### Run the podverse_web application

```
docker exec -d podverse_web_local npm --prefix /tmp start
```

#### Add categories to the database

```
docker exec -d podverse_api_local npm --prefix /tmp run seeds:categories
```

#### Add feed urls to the database

To add podcasts to the database, you first need to add feed urls to the
database, and then run the podcast parser with those feed urls.

You can pass multiple feed urls as a comma-delimited string parameter to the
`npm run scripts:addFeedUrls` command.

A list of sample podcast feed urls can be found at
[podverse-api/docs/sampleFeedUrls.txt]
(https://github.com/podverse/podverse-api/tree/deploy/docs/sampleFeedUrls.txt).

```
docker exec podverse_api_local npm --prefix /tmp run scripts:addFeedUrls
```

#### Parse feed urls to add podcasts and episodes to the database

```
docker exec podverse_api_local npm --prefix /tmp run scripts:parseOrphanFeedUrls
```

"Orphan" feed urls do not have a podcast associated with them.

To parse all non-orphan and public feed urls, you can run:

```
docker exec podverse_api_local npm --prefix /tmp run scripts:parsePublicFeedUrls
```

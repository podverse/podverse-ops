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

### Create and start all containers

WARNING: If you use the letsencrypt for SSL on stage or prod, be careful
not to run the letsencrypt container too many times. Every time the container
starts it requests SSL certificates from letsencrypt, and if you reach that limit,
you won't be able to request new SSL certificates for a week.

```
docker-compose -f docker-compose.local.yml up -d
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
docker exec podverse_api_local npm --prefix /tmp run scripts:addFeedUrls <feed urls>
```

#### Parse feed urls to add podcasts and episodes to the database

"Orphan" feed urls are feed urls that do not have a podcast associated with them.

```
docker exec podverse_api_local npm --prefix /tmp run scripts:parseOrphanFeedUrls
```

To parse all non-orphan and public feed urls, you can run:

```
docker exec podverse_api_local npm --prefix /tmp run scripts:parsePublicFeedUrls
```

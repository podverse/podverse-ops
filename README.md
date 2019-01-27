# podverse-ops

Deployment scripts for the podverse ecosystem.

## How to deploy the Podverse API and Web app

### Prod vs Local

For local development, use the docker-compose.local.yml file.

For production deployment, use the docker-compose.prod.yml file.

### Setup environment variables

Duplicate the config/podverse-web-local.example.env, rename it to config/podverse-web-local.env, and update the environment variables within the file for your environment.

Add your BitPay API key file to config/bitpay/api.key. Check the config/bitpay/api.key.example for more info.

Add your Google API key file to config/google/jwt.keys.json. Check the config/google/jwt.keys.json.example for more info.

### Start a Postgres instance

```
docker-compose -f docker-compose.local.yml up -d podverse_db
```

### Seed with sample data

```
docker-compose -f docker-compose.local.yml up -d podverse_api_seed_db
```

### Start podverse-api

```
docker-compose -f docker-compose.local.yml up -d podverse_api
```

### Start podverse-web

```
docker-compose -f docker-compose.local.yml up -d podverse_web
```

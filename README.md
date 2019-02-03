# podverse-ops

Deployment scripts for the podverse ecosystem

## Getting started

### Local / Stage / Prod

To test the Docker containers locally, use the docker-compose.local.yml file.

For stage deployment, use the docker-compose.stage.yml file, and replace "local"
in commands and filenames with "stage".

For prod deployment, use the docker-compose.prod.yml file, and replace "local"
in commands and filenames with "prod".

### Setup environment variables

Duplicate the config/podverse-api-local.example.env file, rename it to config/podverse-api-local.env, and update all of the environment variables to match what is needed for your environment. Repeat these steps for podverse-db-local.env and podverse-web-local.env.

Add your BitPay API key file to config/bitpay/api.key. Look in the config/bitpay/api.key.example for more info.

Add your Google API key file to config/google/jwt.keys.json. Look in the config/google/jwt.keys.json.example for more info.

### Create and start all containers

WARNING: If you use the letsencrypt for SSL on stage or prod, be careful
not to run the letsencrypt container too many times. Every time the container
starts it requests SSL certificates from letsencrypt, and if you reach that limit,
you won't be able to request new SSL certificates for a week. You may want to remove
podverse_letsencrypt_nginx from the following command while you're testing.

```
docker-compose -f docker-compose.local.yml up -d podverse_nginx_proxy podverse_letsencrypt_nginx podverse_db podverse_api podverse_web
```

### Add categories to the database

```
docker exec -d podverse_api_local npm --prefix /tmp run seeds:categories
```

### Add feed urls to the database

To add podcasts to the database, you first need to add feed urls to the
database, and then run the podcast parser with those feed urls.

You can pass multiple feed urls as a comma-delimited string parameter to the
`npm run scripts:addFeedUrls` command.

A list of sample podcast feed urls can be found in
[podverse-api/docs/sampleFeedUrls.txt](https://github.com/podverse/podverse-api/tree/deploy/docs/sampleFeedUrls.txt).

```
docker exec podverse_api_local npm --prefix /tmp run scripts:addFeedUrls <feed urls>
```

### Parse feed urls to add podcasts and episodes to the database

Orphan feed urls do not have a podcast associated with them.

```
docker exec podverse_api_local npm --prefix /tmp run scripts:parseOrphanFeedUrls
```

To parse all non-orphan and public feed urls, you can run:

```
docker exec podverse_api_local npm --prefix /tmp run scripts:parsePublicFeedUrls
```

### Use SQS to add feed urls to a queue, then parse them

This project uses AWS SQS for its remote queue. There are 5 possible queues,
each with a different priority number 1-5. Only podcasts that match the priority argument you provide will be included with each command.

To add all orphan feeds to the queue:

```
docker exec podverse_api_local npm --prefix /tmp run scripts:addAllOrphanFeedUrlsToQueue -- <priority>
```

To add all non-orphan, public feeds to the queue:

```
docker exec podverse_api_local npm --prefix /tmp run scripts:addAllPublicFeedUrlsToQueue -- <priority>
```

After you have added feed urls to a queue, you can retrieve and then parse
the feed urls by running:

```
docker-compose run --rm podverse_api_parser_worker -c "cd /tmp && npm run scripts/parseFeedUrlsFromQueue -- <priority>"
```

### Schedule parsing with cron

Below is a sample cron file for adding feeds to queues then parsing them at scheduled
times. The sample executes parsing with the following frequencies:

| Priority | Frequency per day |
|-1--------|-2-----------------|
| 2        | 4                 |
| 3        | 6                 |
| 4        | 12                |
| 5        | 24                |

The jobs are staggered by 12 minutes so they don't start at the same time. The containers are removed immediately after they finish running.

```
48 */12 * * * docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run --rm podverse_api_parser_worker npm run scripts:addAllPublicFeedUrlsToQueue -- 1
36 */6  * * * docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run --rm podverse_api_parser_worker npm run scripts:addAllPublicFeedUrlsToQueue -- 2
24 */4  * * * docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run --rm podverse_api_parser_worker npm run scripts:addAllPublicFeedUrlsToQueue -- 3
12 */2  * * * docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run --rm podverse_api_parser_worker npm run scripts:addAllPublicFeedUrlsToQueue -- 4
0  *    * * * docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run --rm podverse_api_parser_worker npm run scripts:addAllPublicFeedUrlsToQueue -- 5
```

Feed parsing happens in worker containers that run continuously, and after the worker
receives a "No messages found" response from the queue, the worker waits for a
timeout period before making another message request to the queue. (This isn't very
efficient. Can we replace it with a webhook?)

In the sample below, a feed parser worker is started for each priority queue with a different timeout value for retrying the message request. Priority queues 1-4 retry once per
hour, while priority queue 5 retries every 15 minutes.

```
docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run -d --name podverse_api_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1 3600000
docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run -d --name podverse_api_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 2 3600000
docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run -d --name podverse_api_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 3 3600000
docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run -d --name podverse_api_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 4 3600000
docker-compose -f /path/to/podverse-ops/docker-compose.stage.yml run -d --name podverse_api_parser_worker_1 podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 5 900000
```

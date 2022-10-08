# podverse-ops

Deployment scripts for the podverse ecosystem

## Getting started

### Local / Stage / Prod

To test the Docker containers locally, use the docker-compose.local.yml file, and replace \#\#\# with "local".

For stage deployment, use the docker-compose.stage.yml file, and replace \#\#\# with "stage".

For prod deployment, use the docker-compose.prod.yml file, and replace \#\#\# with "prod".

### Setup environment variables

Duplicate the config/podverse-api-\#\#\#.example.env file, rename it to config/podverse-api-\#\#\#.env, and update all of the environment variables to match what is needed for your environment. Repeat these steps for podverse-db-\#\#\#.env and podverse-web-\#\#\#.env.

Add your Google API key file to config/google/jwt.keys.json. Look in the config/google/jwt.keys.json.example for more info.

### SSL Setup (Stage/Prod)

Replace the LETSENCRYPT_HOST and LETSENCRYPT_EMAIL environment variables in the docker-compose.###.yml file.

### Create and start all containers

WARNING: If you use the letsencrypt for SSL on stage or prod, be careful
not to run the letsencrypt container too many times. Every time the container
starts it requests SSL certificates from letsencrypt, and if you reach that limit,
you won't be able to request new SSL certificates for a week. For that reason you may
want to remove podverse_letsencrypt_nginx from the following command while you're testing.

First you'll need to create the nginx-proxy network:

```
docker network create nginx-proxy
```

Then run the application containers:

```
docker-compose -f docker-compose.###.yml up -d podverse_nginx_proxy podverse_letsencrypt_nginx podverse_db podverse_api podverse_web
```

### Add podcast categories to the database

```
docker exec -d podverse_api_### npm --prefix /tmp run seeds:categories
```

### Add feed urls to the database

To add podcasts to the database, you first need to add feed urls to the
database, and then run the podcast parser with those feed urls.

You can pass multiple feed urls as a comma-delimited string parameter to the
`npm run scripts:addFeedUrls` command.

A list of sample podcast feed urls can be found in
[podverse-api/docs/sampleFeedUrls.txt](https://github.com/podverse/podverse-api/tree/deploy/docs/sampleFeedUrls.txt).

```
docker exec podverse_api_### npm --prefix /tmp run scripts:addFeedUrls <feed urls>
```

### Parse feed urls to add podcasts and episodes to the database

Orphan feed urls do not have a podcast associated with them.

```
docker exec podverse_api_### npm --prefix /tmp run scripts:parseOrphanFeedUrls
```

To parse all non-orphan and public feed urls, you can run:

```
docker exec podverse_api_### npm --prefix /tmp run scripts:parsePublicFeedUrls
```

### Use SQS to add feed urls to a queue, then parse them

This project uses AWS SQS for its remote queue.

To add all orphan feeds to the queue:

```
docker exec podverse_api_### npm --prefix /tmp run scripts:addAllOrphanFeedUrlsToPriorityQueue
```

To add all non-orphan, public feeds to the queue:

```
docker exec podverse_api_### npm --prefix /tmp run scripts:addAllPublicFeedUrlsToQueue
```

To add all non-authority feedUrls (podcasts that do not have an authorityId):

```
docker exec podverse_api_### npm --prefix /tmp run scripts:addNonPodcastIndexFeedUrlsToPriorityQueue
```

To add all recently updated (according to Podcast Index), public feeds to the priority queue:

```
docker exec podverse_api_### npm --prefix /tmp run scripts:addRecentlyUpdatedFeedUrlsToPriorityQueue
```

After you have added feed urls to a queue, you can retrieve and then parse
the feed urls by running:

```
docker-compose -f docker-compose.###.yml run podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- <retryTimeMS>
```

### Schedule parsing with cron

Below is a sample cron command for adding feeds to queues.

```
0 */6 * * * docker-compose -f /home/mitch/podverse-ops/docker-compose.###.yml run --rm podverse_api_parser_worker npm run scripts:addAllPublicFeedUrlsToQueue
```

Feed parsing happens in worker containers that run continuously, and after the worker
receives a "No messages found" response from the queue, the worker waits for a
timeout period before making another message request to the queue.

```
docker-compose -f /home/mitch/podverse-ops/docker-compose.###.yml run -d --name podverse_api_parser_worker podverse_api_parser_worker npm run scripts:parseFeedUrlsFromQueue -- 1800000
```

### Request Google Analytics pageview data and save to database with cron

Below is a sample cron config for requesting unique pageview data from Google
Analytics, which is used throughout the site for sorting by popularity (not an ideal system for popularity sorting, but it's what we're using for now).

```
0 * * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- clips hour
5 */2 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- clips day
10 */4 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- clips week
15 */6 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- clips month
25 */8 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- clips year
40 */12 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- clips allTime

0 * * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- episodes hour
5 */2 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- episodes day
10 */4 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- episodes week
15 */6 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- episodes month
25 */8 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- episodes year
40 */12 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- episodes allTime

0 * * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- podcasts hour
5 */2 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- podcasts day
10 */4 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- podcasts week
15 */6 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- podcasts month
25 */8 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- podcasts year
40 */12 * * * /usr/local/bin/docker-compose -f /home/mitch/podverse-ops/docker-compose.prod.yml run --rm podverse_api_stats npm run scripts:queryUniquePageviews -- podcasts allTime
```
### Automated Database Backup

You can run the `scripts/db_backup.sh` file with cron to automatically backup the database. Follow steps 1 and 2 in [this tutorial by Rahul Kumar](https://tecadmin.net/install-postgresql-server-on-ubuntu/) to install pg_dump, and follow [this tutorial by Pranav Prakash](https://pranavprakash.net/2017/05/16/automated-postgresql-backups/) to configure the script.

Sample cron command:

```
0 0 * * * /home/mitch/podverse-ops/scripts/db_backup.sh
```

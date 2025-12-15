# Jenkins Deployment Steps (Alpha Environment)

This document outlines the order in which Jenkins deploy jobs must be run for a fresh deploy of Podverse to a new server.

This document assumes you have already published the npm modules and docker images. See the dev/publish/order-for-publishing.md file for more information on publishing.

The infrastructure assumes two separate servers: srv and aux.

srv = hosts podverse-api and podverse-web.

aux = hosts everything else in the infrastructure, specifically the db (postgres), mq (message queue, ActiveMQ), and worker containers (feed parsers and feed update listeners).

## Initialization

- aux_ops_git_pull - makes sure you are using the latest ops docker configs.
- srv_ops_git_pull
- aux_network_create - creates the docker network so the containers can communicate.
- srv_network_create
- aux_db_up - runs the database.
- aux_db_init - initializes the table schema.
- aux_mq_up - runs the message queue.
- aux_workers_pull - pulls the docker image for the worker containers.
- aux_workers_mq_rss_run_parsers_all - runs the rss feed parsers (these pull messages from mq and parse feeds).
- aux_workers_mq_rss_run_live_item_listener - runs the rss live item listener (runs continuously, and adds messages to mq).
- srv_api_up - runs the https data api.
- srv_web_up - runs the web application.

## Cron jobs

- aux_workers_mq_rss_add_recently_updated_feeds_from_podcast_index - polls Podcast Index for a list of the rss feeds with recent updates, then adds them to the mq for parsing (can happen frequently, perhaps every 5 minutes).

These haven't been tested in a while. May need to be updated to work properly.

- TODO: aux_workers_podcast_index_dead_feeds_flag_and_merge - polls Podcast Index for a full list of the rss feeds that have been removed from Podcast Index, and flags those feeds in our system for archival and removal. (once daily)
- TODO: aux_workers_archive_all (once daily, after dead_feeds job)

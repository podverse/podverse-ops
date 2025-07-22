# Order for deploying

This document outlines the order in which Jenkins deploy jobs must be run.

This document assumes you have already published the npm modules and docker images. See the dev/publish/order-for-publishing.md file for more information on publishing.

## Initialization

- alpha_ops_git_pull - make sure you are using the latest ops docker configs
- alpha_network_create - the docker external network used by the infrastructure
- alpha_db_up - start the empty database
- alpha_db_init - import the full schema to the database
- alpha_queue_amtp_up - start the amtp queue
- alpha_workers_up - pull the workers image

## Updates

Pause all scheduled jobs: 
- alpha_workers_archive_all
- alpha_workers_podcast_index_dead_feeds_flag_and_merge
- alpha_workers_queue_rss_add_recently_updated_feeds_from_podcast_index


Update jobs:
- alpha_ops_git_pull - make sure you are using the latest ops docker configs
- to be continued...

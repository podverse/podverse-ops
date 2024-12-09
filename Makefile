

ifeq ($(UNAME),Darwin)
	SHELL := /opt/local/bin/bash
	OS_X  := true
else ifneq (,$(wildcard /etc/redhat-release))
	RHEL := true
else
	OS_DEB  := true
	SHELL := /bin/bash
endif

.PHONY: say_hello
say_hello:
	@echo "Hello Podverse"

.PHONY: local_validate_init
local_validate_init: config/podverse-api-local.env config/podverse-db-local.env config/podverse-web-local.env

config/podverse-api-local.env:
	@echo "Missing: $@"
	@echo "Copying from example file"
	cp ./$@.example ./$@

config/podverse-db-local.env:
	@echo "Missing: $@"
	@echo "Copying from example file"
	cp ./$@.example ./$@

config/podverse-web-local.env:
	@echo "Missing: $@"
	@echo "Copying from example file"
	cp ./$@.example ./$@

.PHONY: local_nginx_proxy
local_nginx_proxy:
	@echo 'Generate new cert'
	test -d proxy/local/certs || mkdir -p proxy/local/certs
	cd proxy/local/certs && openssl genrsa -out podverse-server.key 4096
	cd proxy/local/certs && openssl rsa -in podverse-server.key -out podverse-server.key.insecure
	cd proxy/local/certs && openssl req -new -sha256 -key podverse-server.key -subj "/C=US/ST=Jefferson/L=Grand/O=EXA/OU=MPL/CN=podverse.local" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:podverse.local,DNS:www.podverse.local,DNS:api.podverse.local")) -out podverse-server.csr
	cd proxy/local/certs && openssl x509 -req -days 365 -in podverse-server.csr -signkey podverse-server.key -out podverse-server.crt

.PHONY: local_up_db
local_up_db:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_db -d

.PHONY: local_init_materialized_views
local_init_materialized_views:
# init 
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_db psql -U postgres -d postgres -a -f /opt/migrations/0032_mediaRefs_videos_materialized_view.sql
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_db psql -U postgres -d postgres -a -f /opt/migrations/0037_episodes_most_recent_materialized_view.sql
# have to call REFRESH one time for each table without CONCURRENTLY
# the _refresh make commands use CONCURRENTLY.
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_db psql -U postgres -d postgres -c 'REFRESH MATERIALIZED VIEW "mediaRefs_videos"'
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_db psql -U postgres -d postgres -c 'REFRESH MATERIALIZED VIEW "episodes_most_recent"'

# This materialized view is used when querying for only mediaRefs for video podcasts.
.PHONY: local_materialized_view_mediaRefs_refresh
local_materialized_view_mediaRefs_refresh:
	docker-compose -f docker-compose/local/docker-compose.yml run --name refreshMediaRefsVideosMaterializedView --rm podverse_api_worker npm run scripts:refreshMediaRefsVideosMaterializedView

# This materialized view is used for sorting all episodes by recency.
# It is limited to the past ~21 days currently.
.PHONY: local_materialized_view_episodes_refresh
local_materialized_view_episodes_refresh:
	docker-compose -f docker-compose/local/docker-compose.yml run --name refreshEpisodesMostRecentMaterializedView --rm podverse_api_worker npm run scripts:refreshEpisodesMostRecentMaterializedView

.PHONY: local_up_manticore_server
local_up_manticore_server:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_manticore -d

.PHONY: local_manticore_indexes_init
local_manticore_indexes_init:
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_author --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_media_ref --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_playlist --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_podcast --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_01 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_02 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_03 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_04 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_05 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_06 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_07 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_08 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_09 --verbose
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_10 --verbose
# NOTE! After initializing the indexes, manticore must be restarted to be able to use the indexes
	docker restart podverse_manticore_local

.PHONY: local_manticore_indexes_rotate
local_manticore_indexes_rotate:
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_author --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_media_ref --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_playlist --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_podcast --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_01 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_02 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_03 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_04 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_05 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_06 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_07 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_08 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_09 --rotate --verbose;
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_manticore gosu manticore indexer idx_episode_10 --rotate --verbose;

.PHONY: local_update_schema
local_update_schema:
	db/schema-only/updateSchema.sh

.PHONY: local_up_api
local_up_api:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_api -d

.PHONY: local_up_api_no_cache
local_up_api_no_cache:
	docker-compose -f docker-compose/local/docker-compose.yml build --no-cache podverse_api podverse_api_worker

.PHONY: local_up_web
local_up_web:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_web -d

.PHONY: local_up_web_no_cache
local_up_web_no_cache:
	docker-compose -f docker-compose/local/docker-compose.yml build --no-cache podverse_web

.PHONY: local_up_maintenance_mode
local_up_maintenance_mode:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_maintenance_mode_web -d

.PHONY: local_up_proxy
local_up_proxy:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_nginx_proxy -d

.PHONY: local_down_docker_compose
local_down_docker_compose:
	docker-compose -f docker-compose/local/docker-compose.yml down

# This will add a predefined list of ~30 feed urls to the AWS SQS queue based on their Podcast Index id.
# This is useful for seeding the database with podcast data.
# You may need a valid Podcast Index API keys for the
# PODCAST_INDEX_AUTH_KEY and PODCAST_INDEX_SECRET_KEY env vars.
# Sign up for a key here: https://api.podcastindex.org/
# TODO: is a Podcast Index API actually required by our services?
# TODO: Research how to validate key after it has been required, or post error message explaining the key is missing.
# TODO: Use environment variables to insert the ids as a parameter at the end of the command.
.PHONY: local_add_podcast_index_seed_feeds_to_queue
local_add_podcast_index_seed_feeds_to_queue:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addPodcastIndexSeedFeedsToQueue --rm podverse_api_worker npm run scripts:addFeedsByPodcastIndexIdToQueue -- 5718023,387129,3662287,160817,150842,878147,487548,167137,465231,767934,577105,54545,650774,955598,3758236,203827,879740,393504,575694,921030,41504,5341434,757675,174725,920666,1333070,227573,5465405,5498327,5495489,556715,5485175,202764,830124,66844,4169501,6524027

.PHONY: local_add_podcast_index_seed_feeds_to_queue_small
local_add_podcast_index_seed_feeds_to_queue_small:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addPodcastIndexSeedFeedsToQueue --rm podverse_api_worker npm run scripts:addFeedsByPodcastIndexIdToQueue -- 5718023,387129,3662287,160817

.PHONY: local_add_podcast_index_seed_feeds_with_live_items_to_queue
local_add_podcast_index_seed_feeds_with_live_items_to_queue:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addPodcastIndexSeedFeedsToQueue --rm podverse_api_worker npm run scripts:addFeedsByPodcastIndexIdToQueue -- 4935828,5495489,162612,5461087,486332,480983,3727160,5496786,901876,5498327,4207213,5710520,5465405,5485175,574891,920666,540927,4432692,5718023,41504,3756449,150842,937170,946122,5373053,624721,5700613,288180,955598,6524027

# This will run 3 parsers that pull from different SQS queues.
# The priority queue is used in most cases, but the non-priority queue
# is used for less time sensitive jobs (like doing a full sync with Podcast Index).
# The live queue is used for live streams.
# TODO: Do an environment variable check for AWS credentials.
.PHONY: local_up_parsers
local_up_parsers:
	docker-compose -f docker-compose/local/docker-compose.yml run -d --name --rm podverse_api_parser_1 podverse_api_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 priority
	docker-compose -f docker-compose/local/docker-compose.yml run -d --name --rm podverse_api_parser_2 podverse_api_worker npm run scripts:parseFeedUrlsFromQueue -- 60000
	docker-compose -f docker-compose/local/docker-compose.yml run -d --name --rm podverse_api_parser_3_live podverse_api_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 live

.PHONY: local_down_parsers
local_down_parsers:
# I think down may not work like this, and it's a known issue?
# https://github.com/docker/compose/issues/9627#issuecomment-1196514436
#	docker-compose -f docker-compose/local/docker-compose.yml down podverse_api_parser_1 podverse_api_parser_2 podverse_api_parser_3_live
	docker stop podverse_api_parser_1 podverse_api_parser_2 podverse_api_parser_3_live

# This will request the new feeds added to Podcast Index over the past X milliseconds
# (as defined in the podverse-api-xxxxx.env), and then parse and add them to the database
# one-by-one immediately (without sending the feeds to an SQS queue).
# TODO: Add environment variable check. Make the time-range the request is for human readable in an echo.
.PHONY: local_add_podcast_index_new_feeds
local_add_podcast_index_new_feeds:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addNewFeedUrls --rm podverse_api_worker npm run scripts:addNewFeedsFromPodcastIndex

.PHONY: local_podping_liveitem_listener
local_podping_liveitem_listener:
	docker-compose -f docker-compose/local/docker-compose.yml run -d --name runLiveItemListener podverse_api_worker npm run scripts:podping:runLiveItemListener

.PHONY: local_down_podping_liveitem_listener
local_down_podping_liveitem_listener:
#	docker-compose -f docker-compose/local/docker-compose.yml down runLiveItemListener
	docker stop runLiveItemListener
	docker rm runLiveItemListener

# This will request the updated feeds according to Podcast Index over the past X milliseconds
# (as set as a parameter in seconds to the end of the command), and then add them to the priority SQS queue.
# If that podcastIndexId is not already available in the database,
# this process will not add it as a new feed. It only handles updating existing podcasts.
.PHONY: local_add_podcast_index_recently_updated_feed_urls
local_add_podcast_index_recently_updated_feed_urls:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addRecentlyUpdated --rm podverse_api_worker npm run scripts:addRecentlyUpdatedFeedUrlsToPriorityQueue $$(date -v-5M +%s)

# This will request a list of all dead feeds/podcasts from Podcast Index,
# and then set "isPublic=false" to those podcasts in our database.
.PHONY: local_hide_dead_podcasts_from_podcast_index
local_hide_dead_podcasts_from_podcast_index:
	docker-compose -f docker-compose/local/docker-compose.yml run --name hideDeadPodcasts --rm podverse_api_worker npm run scripts:hideDeadPodcasts

# If an episode has "isPublic=false" and does not have any mediaRefs or playlists
# associated with it, then it will be considered "dead" and deleted from the database.
.PHONY: local_remove_dead_episodes
local_remove_dead_episodes:
	docker-compose -f docker-compose/local/docker-compose.yml run --name removeDeadEpisodes --rm podverse_api_worker npm run scripts:removeDeadEpisodes

# This query gets the Value for Value aka <podcast:value> tag information
# from Podcast Index. Ideally <podcast:value> tag info is available in the RSS feed,
# but Podcast Index has a service called Podcaster Wallet, which serves as a "shim"
# so podcasters can share their <podcast:value> tag info without adding it to their RSS feed.
# To handle this, a few times per day we request from Podcast Index
# a full list of the podcasts that use Podcaster Wallet. Then, in our API,
# when a podcast is requested uses Podcaster Wallet, we make a request to
# Podcast Index to get the <podcast:value> shim data, so we can load it in our apps.
.PHONY: local_update_value_tags_from_podcast_index
local_update_value_tags_from_podcast_index:
	docker-compose -f docker-compose/local/docker-compose.yml run --name updateValueTagEnabledPodcastIdsFromPI --rm podverse_api_worker npm run scripts:podcastindex:updateValueTagEnabledPodcastIdsFromPI

# The stats queries are running for me...but the Matomo API
# does not seem to return the data from the past hour.
# I just emailed Matomo support to ask if there is a delay before
# the data becomes available, or if I'm doing something wrong...
.PHONY: local_stats_queries
local_stats_queries:
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- clips hour
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- clips day
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- clips week
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- clips month
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- clips year
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- clips allTime
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- episodes hour
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- episodes day
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- episodes week
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- episodes month
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- episodes year
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- episodes allTime
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- podcasts hour
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- podcasts day
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- podcasts week
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- podcasts month
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- podcasts year
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- podcasts allTime

.PHONY: local_stats_queries_short
local_stats_queries_short:
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- clips week
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- episodes week
	docker-compose -f docker-compose/local/docker-compose.yml run --rm podverse_api_worker npm run scripts:queryUniquePageviews -- podcasts week

.PHONY: local_up local_up_db local_up_manticore_server local_up_api local_up_web
local_up: local_up_db local_up_manticore_server local_up_api local_up_web

.PHONY: local_down local_down_docker_compose
local_down: local_down_docker_compose

.PHONY: local_refresh local_down local_up
local_refresh: local_down local_up


proxy/local/certs:
	mkdir -p $@

proxy/local/certs/podverse-server.key:
	openssl genrsa -out $@ 4096

proxy/local/certs/podverse-server.key.insecure: proxy/local/certs/podverse-server.key
	openssl rsa -in $< -out $@

proxy/local/certs/podverse-server.csr: proxy/local/certs/podverse-server.key
	openssl req -new -sha256 -key $< -subj "/C=US/ST=Jefferson/L=Grand/O=Podverse/OU=Inra/CN=podverse.local" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:podverse.local,DNS:www.podverse.local,DNS:api.podverse.local")) -out $@

proxy/local/certs/podverse-server.crt: proxy/local/certs/podverse-server.csr
	openssl x509 -req -days 365 -in $< -signkey proxy/local/certs/podverse-server.key -out $@

.PHONY: local_nginx_proxy_cert
local_nginx_proxy_cert: proxy/local/certs proxy/local/certs/podverse-server.key proxy/local/certs/podverse-server.key.insecure proxy/local/certs/podverse-server.csr proxy/local/certs/podverse-server.crt
	@echo 'Generate new cert'

.PHONY: local_git_sub_init
local_git_sub_init:
	git submodule update --init --recursive

.PHONY: stage_clean_manticore
stage_clean_manticore:
	@echo "Cleaning Manticore"
	rm -rf ./manticore/data

.PHONY: prod_cron_init
prod_cron_init:
	crontab cronjobs/prod-podverse-workers

.PHONY: prod_srv_docker-compose_up
prod_srv_docker-compose_up:
	docker-compose -f docker-compose/prod/srv/docker-compose.yml up -d

.PHONY: prod_srv_docker-compose_up-no_dettach
prod_srv_docker-compose_up-no_dettach:
	docker-compose -f docker-compose/prod/srv/docker-compose.yml up

.PHONY: sanbox_db_docker-compose_up
sanbox_db_docker-compose_up:
	docker-compose -f docker-compose/sandbox/db/docker-compose.yml up -d

.PHONY: sanbox_db_docker-compose_up-no_dettach
sanbox_db_docker-compose_up-no_dettach:
	docker-compose -f docker-compose/sandbox/db/docker-compose.yml up

.PHONY: sanbox_srv_docker-compose_up
sanbox_srv_docker-compose_up:
	docker-compose -f docker-compose/sandbox/srv/docker-compose.yml up -d

.PHONY: sanbox_srv_docker-compose_up-no_dettach
sanbox_srv_docker-compose_up-no_dettach:
	docker-compose -f docker-compose/sandbox/srv/docker-compose.yml up

.PHONY: dev_up
dev_up:
	@echo 'Starting devcontainers'
	@devcontainer up --prebuild --workspace-folder . --config .devcontainer/podverse-web/devcontainer.json
	@devcontainer set-up --config .devcontainer/podverse-api/devcontainer.json --container-id podverse_api_local

.PHONY: dev_down
dev_down:
	@echo 'Stopping devcontainers'
	@docker compose -f ./docker-compose/local/docker-compose.yml -f ./.devcontainer/docker-compose.yml down

.PHONY: dev_start_api
dev_start_api:
	@echo 'Starting Podverse API node server'
	@devcontainer exec --config .devcontainer/podverse-api/devcontainer.json --container-id podverse_api_local yarn start

.PHONY: dev_start_web
dev_start_web:
	@echo 'Starting Podverse Web node server'
	@devcontainer exec --config .devcontainer/podverse-web/devcontainer.json --container-id podverse_web_local yarn start

.PHONY: dev_shell_api
dev_shell_api:
	@echo 'Shelling into api container'
	@devcontainer exec --config .devcontainer/podverse-api/devcontainer.json --container-id podverse_api_local bash

.PHONY: dev_shell_web
dev_shell_web:
	@echo 'Shelling into web container'
	@devcontainer exec --config .devcontainer/podverse-web/devcontainer.json --container-id podverse_web_local bash

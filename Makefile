

ifeq ($(UNAME),Darwin)
	SHELL := /opt/local/bin/bash
	OS_X  := true
else ifneq (,$(wildcard /etc/redhat-release))
	RHEL := true
else
	OS_DEB  := true
	SHELL := /bin/bash
endif

say_hello:
	@echo "Hello World"

init_project:
	@echo "doing the work"

local_init_conf:
	cp ./config/podverse-api-local.env.example ./config/podverse-api-local.env
	cp ./config/podverse-db-local.env.example ./config/podverse-db-local.env
	cp ./config/podverse-web-local.env.example ./config/podverse-web-local.env
local_validate_init:
# https://stackoverflow.com/questions/5553352/how-do-i-check-if-file-exists-in-makefile-so-i-can-delete-it

# config/podverse-api-local.env
ifeq ("$(wildcard ./config/podverse-api-local.env)","")
	@echo "Missing: config/podverse-api-local.env"
endif

# config/podverse-db-local.env
ifeq ("$(wildcard ./config/podverse-db-local.env)","")
	@echo "Missing: config/podverse-db-local.env"
endif
# config/podverse-web-local.env
ifeq ("$(wildcard ./config/podverse-web-local.env)","")
	@echo "Missing: config/podverse-web-local.env"
endif
	@echo "Check complete"

local_nginx_proxy:
	@echo 'Generate new cert'
	test -d proxy/local/certs || mkdir -p proxy/local/certs
	cd proxy/local/certs && openssl genrsa -out podverse-server.key 4096
	cd proxy/local/certs && openssl rsa -in podverse-server.key -out podverse-server.key.insecure
	cd proxy/local/certs && openssl req -new -sha256 -key podverse-server.key -subj "/C=US/ST=Jefferson/L=Grand/O=EXA/OU=MPL/CN=podverse.local" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:podverse.local,DNS:www.podverse.local,DNS:api.podverse.local")) -out podverse-server.csr
	cd proxy/local/certs && openssl x509 -req -days 365 -in podverse-server.csr -signkey podverse-server.key -out podverse-server.crt

local_up_db: 
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_db -d

local_init_materialized_views:
# init 
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_db psql -U postgres -d postgres -a -f /opt/migrations/0032_mediaRefs_videos_materialized_view.sql
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_db psql -U postgres -d postgres -a -f /opt/migrations/0037_episodes_most_recent_materialized_view.sql
# have to call REFRESH one time for each table without CONCURRENTLY
# the _refresh make commands use CONCURRENTLY.
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_db psql -U postgres -d postgres -c 'REFRESH MATERIALIZED VIEW "mediaRefs_videos"'
	docker-compose -f docker-compose/local/docker-compose.yml exec podverse_db psql -U postgres -d postgres -c 'REFRESH MATERIALIZED VIEW "episodes_most_recent"'

# This materialized view is used when querying for only mediaRefs for video podcasts.
local_materialized_view_mediaRefs_refresh:
	docker-compose -f docker-compose/local/docker-compose.yml run --name refreshMediaRefsVideosMaterializedView --rm podverse_api_worker npm run scripts:refreshMediaRefsVideosMaterializedView

# This materialized view is used for sorting all episodes by recency.
# It is limited to the past ~21 days currently.
local_materialized_view_episodes_refresh:
	docker-compose -f docker-compose/local/docker-compose.yml run --name refreshEpisodesMostRecentMaterializedView --rm podverse_api_worker npm run scripts:refreshEpisodesMostRecentMaterializedView

local_up_manticore_server:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_manticore -d

local_manticore_indexes_init:
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
# after initializing the indexes, manticore must be restarted to be able to use the indexes
	docker restart podverse_manticore_local

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

local_up_api:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_api -d

local_up_api_no_cache:
	docker-compose -f docker-compose/local/docker-compose.yml build --no-cache podverse_api podverse_api_worker

local_up_web:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_web -d

local_up_web_no_cache:
	docker-compose -f docker-compose/local/docker-compose.yml build --no-cache podverse_web

local_up_proxy:
	docker-compose -f docker-compose/local/docker-compose.yml up podverse_nginx_proxy -d

local_down_docker_compose:
	docker-compose -f docker-compose/local/docker-compose.yml down

# This will add a predefined list of ~30 feed urls to the AWS SQS queue based on their Podcast Index id.
# This is useful for seeding the database with podcast data.
local_add_podcast_index_seed_feeds_to_queue:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addPodcastIndexSeedFeedsToQueue --rm podverse_api_worker npm run scripts:addFeedsByPodcastIndexIdToQueue -- 5718023,387129,3662287,160817,150842,878147,487548,167137,465231,767934,577105,54545,650774,955598,3758236,203827,879740,393504,575694,921030,41504,5341434,757675,174725,920666,1333070,227573,5465405,5498327,5495489,556715,5485175,202764,830124,66844,4169501

local_add_podcast_index_seed_feeds_to_queue_small:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addPodcastIndexSeedFeedsToQueue --rm podverse_api_worker npm run scripts:addFeedsByPodcastIndexIdToQueue -- 5718023,387129,3662287,160817

# This will run 3 parsers that pull from different SQS queues.
# The priority queue is used in most cases, but the non-priority queue
# is used for less time sensitive jobs (like doing a full sync with Podcast Index).
# The live queue is used for live streams.
local_up_parsers:
	docker-compose -f docker-compose/local/docker-compose.yml run -d --name podverse_api_parser_1 podverse_api_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 priority
	docker-compose -f docker-compose/local/docker-compose.yml run -d --name podverse_api_parser_2 podverse_api_worker npm run scripts:parseFeedUrlsFromQueue -- 60000
	docker-compose -f docker-compose/local/docker-compose.yml run -d --name podverse_api_parser_3_live podverse_api_worker npm run scripts:parseFeedUrlsFromQueue -- 60000 live

local_down_parsers:
# I think down may not work like this, and it's a known issue?
# https://github.com/docker/compose/issues/9627#issuecomment-1196514436
#	docker-compose -f docker-compose/local/docker-compose.yml down podverse_api_parser_1 podverse_api_parser_2 podverse_api_parser_3_live
	docker stop podverse_api_parser_1 podverse_api_parser_2 podverse_api_parser_3_live
	docker rm podverse_api_parser_1 podverse_api_parser_2 podverse_api_parser_3_live

# This will request the new feeds added to Podcast Index over the past X milliseconds
# (as defined in the podverse-api-xxxxx.env), and then parse and add them to the database
# one-by-one immediately (without sending the feeds to an SQS queue).
local_add_podcast_index_new_feeds:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addNewFeedUrls --rm podverse_api_worker npm run scripts:addNewFeedsFromPodcastIndex

local_podping_liveitem_listener:
	docker-compose -f docker-compose/local/docker-compose.yml run -d --name runLiveItemListener podverse_api_worker npm run scripts:podping:runLiveItemListener

local_down_podping_liveitem_listener:
#	docker-compose -f docker-compose/local/docker-compose.yml down runLiveItemListener
	docker stop runLiveItemListener
	docker rm runLiveItemListener

# This will request the updated feeds according to Podcast Index over the past X milliseconds
# (as set as a parameter in seconds to the end of the command), and then add them to the priority SQS queue.
# If that podcastIndexId is not already available in the database,
# this process will not add it as a new feed. It only handles updating existing podcasts.
local_add_podcast_index_recently_updated_feed_urls:
	docker-compose -f docker-compose/local/docker-compose.yml run --name addRecentlyUpdated --rm podverse_api_worker npm run scripts:addRecentlyUpdatedFeedUrlsToPriorityQueue $$(date -v-5M +%s)

# This will request a list of all dead feeds/podcasts from Podcast Index,
# and then set "isPublic=false" to those podcasts in our database.
local_hide_dead_podcasts_from_podcast_index:
	docker-compose -f docker-compose/local/docker-compose.yml run --name hideDeadPodcasts --rm podverse_api_worker npm run scripts:hideDeadPodcasts

# If an episode has "isPublic=false" and does not have any mediaRefs or playlists
# associated with it, then it will be considered "dead" and deleted from the database.
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
local_update_value_tags_from_podcast_index:
	docker-compose -f docker-compose/local/docker-compose.yml run --name updateValueTagEnabledPodcastIdsFromPI --rm podverse_api_worker npm run scripts:podcastindex:updateValueTagEnabledPodcastIdsFromPI

# The stats queries are running for me...but the Matomo API
# does not seem to return the data from the past hour.
# I just emailed Matomo support to ask if there is a delay before
# the data becomes available, or if I'm doing something wrong...
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

stage_clean_manticore:
	@echo "Cleaning Manticore"
	rm -rf ./manticore/data

prod_cron_init:
	crontab cronjobs/prod-podverse-workers
#!/bin/bash

# drop the materialized view
/usr/bin/docker exec -i podverse_db_prod psql -U postgres -c 'DROP MATERIALIZED VIEW "episodes_most_recent"'

# create the materialized view
/usr/bin/docker exec -i podverse_db_prod psql -U postgres -c 'CREATE MATERIALIZED VIEW "episodes_most_recent" AS SELECT e.* FROM "episodes" e WHERE e."isPublic" = true AND e."pubDate" > (NOW() - interval $$14 days$$) AND e."pubDate" < (NOW() + interval $$1 days$$)'

# create index on unique id
/usr/bin/docker exec -i podverse_db_prod psql -U postgres -c 'CREATE UNIQUE INDEX CONCURRENTLY "IDX_episodes_most_recent_id" ON "episodes_most_recent" (id)'

# create compound index on podcastId, isPublic, and pubDate
/usr/bin/docker exec -i podverse_db_prod psql -U postgres -c 'CREATE INDEX CONCURRENTLY "IDX_episodes_most_recent_podcastId_isPublic_pubDate" ON public."episodes_most_recent" USING btree ("podcastId", "isPublic", "pubDate")'

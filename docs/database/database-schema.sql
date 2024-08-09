/*
NOTES:

- The `id` column is a SERIAL column that is used as the primary key for every table.

- The `id_text` column is only intended for tables where the data is available as urls.
  For example, https://podverse.fm/podcast/abc123def456, the `id_text` column would be `abc123def456`.

- The `slug` column is not required, but functions as an alternative for `id_text`.
  For example, https://podverse.fm/podcast/podcasting-20 would have a `slug` column with the value `podcasting-20`.

- The `podcast_index_id` ensures that our database only contains feed data that is available in the Podcast Index API.

- The columns that are within top-level tables, like channel, are intended to be the most essential information,
  and information that is useful for identifying what the channel corresponds with if you are viewing the database
  in a tool like pgAdmin. Example: title makes it easy to see which id corresponds with a podcast you are looking for,
  and description and author can help identify different podcasts with the same title.

*/

-- TODO: many TEXT columns should be changed to VARCHAR(255) or similar to prevent abuse.

-- Helpers

CREATE DOMAIN medium_type AS TEXT
CHECK (VALUE IN (
    'podcast', 'music', 'video', 'film', 'audiobook', 'newsletter', 'blog', 'publisher', 'course',
    'podcastL', 'musicL', 'videoL', 'filmL', 'audiobookL', 'newsletterL', 'blogL', 'publisherL', 'courseL', 'mixed'
));

CREATE DOMAIN numeric_20_11 AS NUMERIC(20, 11);

-- Init tables

CREATE TABLE channel (
    id SERIAL PRIMARY KEY,
    id_text VARCHAR(14) UNIQUE NOT NULL,
    podcast_index_id INTEGER UNIQUE NOT NULL,
    feed_url TEXT UNIQUE NOT NULL,
    podcast_guid UUID UNIQUE, -- As defined by the Podcast Index spec.
    guid VARCHAR, -- Deprecated. The older RSS guid style, which is less reliable.
    title TEXT,
    description TEXT,
    medium medium_type,

    -- TODO: categories, how to best handle to account for sub-categories?

    -- Used to prevent another thread from parsing the same feed.
    -- Set to current time at beginning of parsing, and NULL at end of parsing. 
    -- This is to prevent multiple threads from parsing the same feed.
    -- If is_parsing is over X minutes old, assume last parsing failed and proceed to parse.
    is_parsing DATE
);

CREATE UNIQUE INDEX channel_podcast_guid_unique ON channel(podcast_guid) WHERE podcast_guid IS NOT NULL;

CREATE TABLE item (
    id SERIAL PRIMARY KEY,
    id_text VARCHAR(14) UNIQUE NOT NULL,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
    -- TODO: add item columns
);

CREATE TABLE channel_about (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    author TEXT,
    episode_count INTEGER,
    explicit BOOLEAN,
    itunes_type TEXT CHECK (itunes_type IN ('episodic', 'serial')),
    language TEXT NOT NULL,
    website_link_url TEXT
);

CREATE TABLE channel_funding (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    label TEXT
);

CREATE TABLE channel_image (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    image_width_size INTEGER -- <podcast:image> must have a width specified, but older image tags will not, so allow null.
);

CREATE TABLE channel_live_item (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'live', 'ended')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP
);

CREATE TABLE channel_podroll (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
);

CREATE TABLE channel_trailer (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    title TEXT,
    url TEXT NOT NULL,
    pub_date TIMESTAMP NOT NULL,
    length INTEGER,
    type TEXT,
    season INTEGER
);

CREATE TABLE chat (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    channel_live_item_id INTEGER REFERENCES channel_live_item(id) ON DELETE CASCADE,
    server TEXT NOT NULL,
    protocol TEXT NOT NULL,
    account_id TEXT,
    space TEXT
);

CREATE TABLE feed_info (
  id SERIAL PRIMARY KEY,
  channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
  publisher_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
  CHECK (
    (channel_id IS NOT NULL AND publisher_id IS NULL) OR 
    (channel_id IS NULL AND publisher_id IS NOT NULL)
  ),
  content_type TEXT,
  last_http_status INTEGER,
  last_crawl_time TIMESTAMP,
  last_good_http_status_time TIMESTAMP,
  last_parse_time TIMESTAMP,
  last_update_time TIMESTAMP,
  crawl_errors INTEGER DEFAULT 0,
  parse_errors INTEGER DEFAULT 0,
  locked BOOLEAN DEFAULT FALSE
);

CREATE TABLE location (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    geo TEXT,
    osm TEXT,
    CHECK (
      (geo IS NOT NULL AND osm IS NULL) OR 
      (geo IS NULL AND osm IS NOT NULL)
    )
);

CREATE TABLE person (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    name TEXT,
    role TEXT,
    person_group TEXT DEFAULT 'cast', -- group is a reserved keyword in sql
    img TEXT,
    href TEXT
);

-- TODO: write the publisher table schema
-- see https://github.com/Podcastindex-org/podcast-namespace/blob/ccfb191c98762ba31f98620bd1ba30c1822f6fbd/publishers/publishers.md
CREATE TABLE publisher (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
);

CREATE TABLE remote_item (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    podroll_id INTEGER REFERENCES channel_podroll(id),
    publisher_id INTEGER REFERENCES publisher(id),
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    feed_guid UUID NOT NULL,
    feed_url TEXT,
    item_guid TEXT,
    medium medium_type,
    title TEXT
);

CREATE TABLE social_interact (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    protocol TEXT NOT NULL,
    uri TEXT NOT NULL,
    account_id TEXT,
    account_url TEXT,
    priority INTEGER
);

CREATE TABLE value_tag (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    method TEXT NOT NULL,
    suggested numeric_20_11
);

CREATE TABLE value_tag_receipient (
    id SERIAL PRIMARY KEY,
    value_tag_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    address TEXT NOT NULL,
    split numeric_20_11 NOT NULL,
    name TEXT,
    custom_key TEXT,
    custom_value TEXT,
    fee BOOLEAN DEFAULT FALSE
);

CREATE TABLE value_tag_time_split (
    id SERIAL PRIMARY KEY,
    value_tag_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    start_time INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    remote_start_time INTEGER DEFAULT 0,
    remote_percentage INTEGER DEFAULT 100
);

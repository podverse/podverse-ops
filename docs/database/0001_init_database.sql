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

CREATE DOMAIN medium_type AS TEXT CHECK (VALUE IN (
    'podcast', 'music', 'video', 'film', 'audiobook', 'newsletter', 'blog', 'publisher', 'course',
    'podcastL', 'musicL', 'videoL', 'filmL', 'audiobookL', 'newsletterL', 'blogL', 'publisherL', 'courseL', 'mixed'
));

CREATE DOMAIN short_id AS VARCHAR(14);
CREATE DOMAIN varchar_short AS VARCHAR(50);
CREATE DOMAIN varchar_medium AS VARCHAR(255);
CREATE DOMAIN varchar_long AS VARCHAR(5000);
CREATE DOMAIN varchar_fqdn AS VARCHAR(253);
CREATE DOMAIN varchar_uri AS VARCHAR(2083);
CREATE DOMAIN varchar_url AS VARCHAR(2083) CHECK (VALUE ~ '^https?://|^http?://');

CREATE DOMAIN numeric_20_11 AS NUMERIC(20, 11);

-- Init tables

-- TODO: should every table have a created_at and updated_at column?
-- or only some tables? or none?

CREATE TABLE channel (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL,
    podcast_index_id INTEGER UNIQUE NOT NULL,
    feed_url varchar_url UNIQUE NOT NULL,
    podcast_guid UUID UNIQUE, -- As defined by the Podcast Index spec.
    title varchar_medium,
    sortable_title varchar_short, -- all lowercase, ignores articles at beginning of title
    description varchar_long,
    medium medium_type,

    -- channels with seasons need to be rendered in client apps differently.
    -- you can only determine if a channel is in a "season" format is by finding
    -- the <itunes:season> tag in an item in that channel.
    has_season BOOLEAN DEFAULT FALSE,
    
    -- TODO: should we hash the last parsed feed, so we can compare it to the hash of
    -- a feed before completely parsing it, to check if it has changed before continuing?

    -- TODO: categories, how to best handle to account for sub-categories?

    -- channels that have a PI value tag require special handling to request value_tag data
    -- from the Podcast Index API.
    has_podcast_index_value_tags BOOLEAN DEFAULT FALSE,

    -- Used to prevent another thread from parsing the same feed.
    -- Set to current time at beginning of parsing, and NULL at end of parsing. 
    -- This is to prevent multiple threads from parsing the same feed.
    -- If is_parsing is over X minutes old, assume last parsing failed and proceed to parse.
    is_parsing TIMESTAMP
);

CREATE UNIQUE INDEX channel_podcast_guid_unique ON channel(podcast_guid) WHERE podcast_guid IS NOT NULL;

CREATE TABLE item (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    guid varchar_uri -- Deprecated. The older RSS guid style, which is less reliable.
    -- TODO: add item columns
);

CREATE TABLE live_item (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'live', 'ended')),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    chat_web_url varchar_url
);

CREATE TABLE channel_about (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    author varchar_medium,
    episode_count INTEGER,
    explicit BOOLEAN,
    itunes_type TEXT CHECK (itunes_type IN ('episodic', 'serial')),
    language varchar_short NOT NULL,
    website_link_url varchar_url
);

CREATE TABLE channel_funding (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    title varchar_medium
);

CREATE TABLE channel_internal_settings (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    embed_approved_media_url_paths TEXT,
    flag_status TEXT CHECK (flag_status IN ('none', 'spam', 'takedown', 'other', 'always-allow'))
);

CREATE TABLE channel_podroll (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
);

CREATE TABLE channel_trailer (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    title varchar_medium,
    url varchar_url NOT NULL,
    pub_date TIMESTAMP NOT NULL, -- TODO: does this need timezone handling?
    length INTEGER,
    type varchar_short,
    season INTEGER
);

CREATE TABLE chat (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    live_item_id INTEGER REFERENCES live_item(id) ON DELETE CASCADE,
    server varchar_fqdn NOT NULL,
    protocol varchar_short,
    account_id varchar_medium,
    space varchar_medium
);

CREATE TABLE feed (
  id SERIAL PRIMARY KEY,
  channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
  publisher_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
  CHECK (
    (channel_id IS NOT NULL AND publisher_id IS NULL) OR 
    (channel_id IS NULL AND publisher_id IS NOT NULL)
  ),
  content_type varchar_short,
  -- 0 to 5, 0 will only be parsed when PI API reports an update,
  -- higher parsing_priority will be parsed more frequently on a schedule.
  parsing_priority INTEGER DEFAULT 0,
  last_http_status INTEGER,
  last_crawl_time TIMESTAMP,
  last_good_http_status_time TIMESTAMP,
  last_parse_time TIMESTAMP,
  last_update_time TIMESTAMP,
  crawl_errors INTEGER DEFAULT 0,
  parse_errors INTEGER DEFAULT 0,
  locked BOOLEAN DEFAULT FALSE
);

CREATE TABLE image (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    image_width_size INTEGER, -- <podcast:image> must have a width specified, but older image tags will not, so allow null.
    -- If true, then the image is hosted by us in a service like S3.
    -- When is_resized images are deleted, the corresponding image in S3
    -- should also be deleted.
    is_resized BOOLEAN DEFAULT FALSE
);

CREATE TABLE item_chapters (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    type varchar_short NOT NULL,
    version varchar_short NOT NULL
);

CREATE TABLE item_chapter (
    id SERIAL PRIMARY KEY,
    item_chapters_file_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    start_time numeric_20_11 NOT NULL,
    title varchar_medium
);

CREATE TABLE item_soundbite (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    start_time INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    title varchar_medium
);

CREATE TABLE item_transcript (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    type varchar_short NOT NULL,
    language varchar_short,
    rel VARCHAR(50) CHECK (rel IS NULL OR rel = 'captions')
);

CREATE TABLE location (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    geo varchar_medium,
    osm varchar_medium,
    CHECK (
      (geo IS NOT NULL AND osm IS NULL) OR 
      (geo IS NULL AND osm IS NOT NULL)
    )
);

-- TODO: write notifications table

CREATE TABLE person (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    name varchar_medium,
    role varchar_medium,
    person_group TEXT DEFAULT 'cast', -- group is a reserved keyword in sql
    img varchar_url,
    href varchar_url
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
    feed_url varchar_url,
    item_guid varchar_uri,
    medium medium_type,
    title varchar_medium
);

CREATE TABLE social_interact (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    protocol varchar_short NOT NULL,
    uri varchar_uri NOT NULL,
    account_id varchar_medium,
    account_url varchar_url,
    priority INTEGER
);

-- TODO: write stats solution (further down the road)

CREATE TABLE value_tag (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    method varchar_short NOT NULL,
    suggested numeric_20_11
);

CREATE TABLE value_tag_receipient (
    id SERIAL PRIMARY KEY,
    value_tag_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    address varchar_long NOT NULL,
    split numeric_20_11 NOT NULL,
    name varchar_medium,
    custom_key varchar_long,
    custom_value varchar_long,
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

/*

PODCASTING 2.0 DATABASE SCHEMA

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

-- Helpers

CREATE DOMAIN short_id AS VARCHAR(14);
CREATE DOMAIN varchar_short AS VARCHAR(50);
CREATE DOMAIN varchar_normal AS VARCHAR(255);
CREATE DOMAIN varchar_long AS VARCHAR(2500);

CREATE DOMAIN varchar_email AS VARCHAR(255) CHECK (VALUE ~ '^.+@.+\..+$');
CREATE DOMAIN varchar_fqdn AS VARCHAR(253);
CREATE DOMAIN varchar_guid AS VARCHAR(36);
CREATE DOMAIN varchar_password AS VARCHAR(36);
CREATE DOMAIN varchar_slug AS VARCHAR(100);
CREATE DOMAIN varchar_uri AS VARCHAR(2083);
CREATE DOMAIN varchar_url AS VARCHAR(2083) CHECK (VALUE ~ '^https?://|^http?://');

CREATE DOMAIN numeric_20_11 AS NUMERIC(20, 11);

-- Init tables

-- TODO: should every table have a created_at and updated_at column?
-- or only some tables? or none?

--** FEED > FLAG STATUS

CREATE TABLE feed_flag_status (
    id SERIAL PRIMARY KEY,
    status TEXT UNIQUE CHECK (status IN ('none', 'spam', 'takedown', 'other', 'always-allow'))
);

INSERT INTO feed_flag_status (status) VALUES ('none'), ('spam'), ('takedown'), ('other'), ('always-allow');

--** FEED

CREATE TABLE feed (
  id SERIAL PRIMARY KEY,
  url varchar_url UNIQUE NOT NULL,

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
  
  feed_flag_status_id INTEGER NOT NULL REFERENCES feed_flag_status(id),

  -- Used to prevent another thread from parsing the same feed.
  -- Set to current time at beginning of parsing, and NULL at end of parsing. 
  -- This is to prevent multiple threads from parsing the same feed.
  -- If is_parsing is over X minutes old, assume last parsing failed and proceed to parse.
  is_parsing TIMESTAMP,
  container_id VARCHAR(12)
);

--** CHANNEL

-- <channel>
CREATE TABLE channel (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL,
    slug varchar_slug,
    feed_id INTEGER NOT NULL REFERENCES feed(id) ON DELETE CASCADE,
    podcast_index_id INTEGER UNIQUE NOT NULL,
    podcast_guid UUID UNIQUE, -- <podcast:guid>
    title varchar_normal,
    sortable_title varchar_short, -- all lowercase, ignores articles at beginning of title
    -- TODO: should we hash the last parsed feed, so we can compare it to the hash of
    -- a feed before completely parsing it, to check if it has changed before continuing?

    -- TODO: categories, how to best handle to account for sub-categories?

    -- channels that have a PI value tag require special handling to request value_tag data
    -- from the Podcast Index API.
    has_podcast_index_value_tags BOOLEAN DEFAULT FALSE,

    -- hidden items are no longer available in the rss feed, but are still in the database.
    hidden BOOLEAN DEFAULT FALSE,
    -- markedForDeletion items are no longer available in the rss feed, and may be able to be deleted.
    marked_for_deletion BOOLEAN DEFAULT FALSE
);

CREATE UNIQUE INDEX channel_podcast_guid_unique ON channel(podcast_guid) WHERE podcast_guid IS NOT NULL;
CREATE UNIQUE INDEX channel_slug ON channel(slug) WHERE slug IS NOT NULL;

--** CHANNEL > ABOUT > ITUNES TYPE

-- <itunes:type>
CREATE TABLE channel_itunes_type (
    id SERIAL PRIMARY KEY,
    itunes_type TEXT UNIQUE CHECK (itunes_type IN ('episodic', 'serial'))
);

INSERT INTO channel_itunes_type (itunes_type) VALUES ('episodic'), ('serial');

--** CHANNEL > ABOUT

CREATE TABLE channel_about (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    author varchar_normal, -- <itunes:author> and <author>
    episode_count INTEGER, -- aggregated count for convenience
    explicit BOOLEAN, -- <itunes:explicit>
    itunes_type_id INTEGER REFERENCES channel_itunes_type(id),
    language varchar_short NOT NULL, -- <language>
    website_link_url varchar_url -- <link>
);

CREATE TABLE category (
    node_text varchar_normal NOT NULL, -- <itunes:category>
    display_name varchar_normal NOT NULL, -- our own display name for the category
    slug varchar_normal NOT NULL
);

CREATE TABLE channel_category (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES channel_category(id) ON DELETE CASCADE
);

--** CHANNEL > INTERNAL SETTINGS

CREATE TABLE channel_internal_settings (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    -- needed to approve which web domains can override the player with query params.
    -- this prevents malicious parties from misrepresenting the podcast contents on another website.
    embed_approved_media_url_paths TEXT
);

--** CHANNEL > PODROLL

-- <podcast:podroll>
CREATE TABLE channel_podroll (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
);

--** CHANNEL > SEASON

-- channels with seasons need to be rendered in client apps differently.
-- you can only determine if a channel is in a "season" format is by finding
-- the <itunes:season> tag in an item in that channel.

-- NOTE: A channel season does not exist in the Podcasting 2.0 spec,
-- but it is useful for organizing seasons at the channel level,
-- and could be in the P2.0 spec someday.

CREATE TABLE channel_season (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    number INTEGER NOT NULL,
    UNIQUE (channel_id, number),
    name varchar_normal
);

--** CHANNEL > TRAILER

-- <podcast:trailer>
CREATE TABLE channel_trailer (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    title varchar_normal,
    url varchar_url NOT NULL,
    pub_date TIMESTAMPTZ NOT NULL,
    length INTEGER,
    type varchar_short,
    season INTEGER
);

--** ITEM

-- <item>
CREATE TABLE item (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL,
    slug varchar_slug,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    guid varchar_uri, -- <guid>
    pub_date TIMESTAMPTZ, -- <pubDate>
    title varchar_normal, -- <title>

    -- hidden items are no longer available in the rss feed, but are still in the database.
    hidden BOOLEAN DEFAULT FALSE,
    -- markedForDeletion items are no longer available in the rss feed, and may be able to be deleted.
    marked_for_deletion BOOLEAN DEFAULT FALSE
);

CREATE UNIQUE INDEX item_slug ON item(slug) WHERE slug IS NOT NULL;

--** ITEM > ABOUT > ITUNES TYPE

-- <itunes:episodeType>
CREATE TABLE item_itunes_episode_type (
    id SERIAL PRIMARY KEY,
    itunes_episode_type TEXT UNIQUE CHECK (itunes_episode_type IN ('full', 'trailer', 'bonus'))
);

INSERT INTO item_itunes_episode_type (itunes_episode_type) VALUES ('full'), ('trailer'), ('bonus');

--** ITEM > ABOUT

CREATE TABLE item_about (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    duration INTEGER, -- <itunes:duration>
    explicit BOOLEAN, -- <itunes:explicit>
    website_link_url varchar_url, -- <link>
    item_itunes_episode_type_id INTEGER REFERENCES item_itunes_episode_type(id)
);

--** ITEM > CONTENT LINK

-- <podcast:contentLink>
CREATE TABLE content_link (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    href varchar_url NOT NULL,
    title varchar_normal
);

--** ITEM > CHAPTERS

-- <podcast:chapters>
CREATE TABLE item_chapters (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    type varchar_short NOT NULL,
    last_http_status INTEGER,
    last_crawl_time TIMESTAMP,
    last_good_http_status_time TIMESTAMP,
    last_parse_time TIMESTAMP,
    last_update_time TIMESTAMP,
    crawl_errors INTEGER DEFAULT 0,
    parse_errors INTEGER DEFAULT 0
);

-- corresponds with jsonChapters.md example file
CREATE TABLE item_chapter (
    id SERIAL PRIMARY KEY,
    text_id short_id UNIQUE NOT NULL,
    item_chapters_file_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,

    -- the hash is used for comparison, to determine if new chapters should be inserted
    -- after re-parsing an existing chapters file. 
    hash varchar_guid NOT NULL,

    start_time numeric_20_11 NOT NULL,
    end_time numeric_20_11,
    title varchar_normal,
    web_url varchar_url,
    table_of_contents BOOLEAN DEFAULT TRUE
);

--** ITEM > ENCLOSURE (AKA ALTERNATE ENCLOSURE)

-- <podcast:alternateEnclosure>
-- NOTE: the older <enclosure> tag style is integrated into the item_enclosure table.
CREATE TABLE item_enclosure (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    length INTEGER,
    bitrate numeric_20_11,
    height INTEGER,
    language varchar_short,
    title varchar_short,
    rel varchar_short,
    codecs varchar_short,
    item_enclosure_default BOOLEAN DEFAULT FALSE
);

CREATE TABLE item_enclosure_source (
    id SERIAL PRIMARY KEY,
    item_enclosure_id INTEGER NOT NULL REFERENCES item_enclosure(id) ON DELETE CASCADE,
    uri varchar_uri NOT NULL,
    content_type varchar_short
);

CREATE TABLE item_enclosure_integrity (
    id SERIAL PRIMARY KEY,
    item_enclosure_id INTEGER NOT NULL REFERENCES item_enclosure_source(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('sri', 'pgp-signature')),
    value varchar_long NOT NULL
);

--** ITEM > SEASON

-- <podcast:season>
CREATE TABLE item_season (
    id SERIAL PRIMARY KEY,
    channel_season_id INTEGER NOT NULL REFERENCES channel_season(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    title varchar_normal
);

--** ITEM > SEASON > EPISODE

-- <podcast:episode>
CREATE TABLE item_season_episode (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    display varchar_short,
    episode_number numeric_20_11 NOT NULL
);

--** ITEM > SOUNDBITE

-- <podcast:soundbite>
CREATE TABLE item_soundbite (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    start_time INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    title varchar_normal
);

--** ITEM > TRANSCRIPT

-- <podcast:transcript>
CREATE TABLE item_transcript (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    type varchar_short NOT NULL,
    language varchar_short,
    rel VARCHAR(50) CHECK (rel IS NULL OR rel = 'captions')
);

--** LIVE ITEM > STATUS

CREATE TABLE live_item_status (
    id SERIAL PRIMARY KEY,
    status TEXT UNIQUE CHECK (status IN ('pending', 'live', 'ended'))
);

INSERT INTO live_item_status (status) VALUES ('pending'), ('live'), ('ended');

--** LIVE ITEM

-- <podcast:liveItem>
CREATE TABLE live_item (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    live_item_status_id INTEGER NOT NULL REFERENCES live_item_status(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    chat_web_url varchar_url
);

--** CROSS-CUTTING INHERITANCE TABLES

--** CHAT

-- <podcast:chat>
CREATE TABLE chat_base (
    id SERIAL PRIMARY KEY,
    server varchar_fqdn NOT NULL,
    protocol varchar_short,
    account_id varchar_normal,
    space varchar_normal
);

CREATE TABLE channel_chat (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (chat_base);

CREATE TABLE item_chat (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (chat_base);

--** DESCRIPTION

-- <description> AND possibly other tags that contain a description.
CREATE TABLE description_base (
    id SERIAL PRIMARY KEY,
    value varchar_long NOT NULL
);

CREATE TABLE channel_description (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (description_base);

CREATE TABLE item_description (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (description_base);

--** FUNDING

-- <podcast:funding>
CREATE TABLE funding_base (
    id SERIAL PRIMARY KEY,
    url varchar_url NOT NULL,
    title varchar_normal
);

CREATE TABLE channel_funding (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (funding_base);

CREATE TABLE item_funding (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (funding_base);

--** IMAGE

-- <podcast:image> AND all other image tags in the rss feed.
-- older image tag data will be adapted into the image_base table.
CREATE TABLE image_base (
    id SERIAL PRIMARY KEY,
    url varchar_url NOT NULL,
    image_width_size INTEGER, -- <podcast:image> must have a width specified, but older image tags will not, so allow null.

    -- If true, then the image is hosted by us in a service like S3.
    -- When is_resized images are deleted, the corresponding image in S3
    -- should also be deleted.
    is_resized BOOLEAN DEFAULT FALSE
);

CREATE TABLE channel_image (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (image_base);

CREATE TABLE chapter_image (
    chapter_id INTEGER NOT NULL REFERENCES chapter(id) ON DELETE CASCADE
) INHERITS (image_base);

CREATE TABLE item_image (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (image_base);

--** LICENSE

-- <podcast:license>
CREATE TABLE license_base (
    id SERIAL PRIMARY KEY,
    type varchar_normal NOT NULL,
    url varchar_url NOT NULL
);

CREATE TABLE channel_license (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (license_base);

CREATE TABLE item_license (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (license_base);

--** LOCATION

-- <podcast:location>
CREATE TABLE location_base (
    id SERIAL PRIMARY KEY,
    geo varchar_normal,
    osm varchar_normal,
    CHECK (
      (geo IS NOT NULL AND osm IS NULL) OR 
      (geo IS NULL AND osm IS NOT NULL)
    )
);

CREATE TABLE item_chapter_location (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE
) INHERITS (location_base);

CREATE TABLE channel_location (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (location_base);

CREATE TABLE item_location (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (location_base);

--** REMOTE ITEM

-- <podcast:remoteItem>
CREATE TABLE remote_item_base (
    id SERIAL PRIMARY KEY,
    feed_guid UUID NOT NULL,
    feed_url varchar_url,
    item_guid varchar_uri,
    title varchar_normal
);

CREATE TABLE channel_remote_item (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (remote_item_base);

CREATE TABLE item_remote_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (remote_item_base);

CREATE TABLE podroll_remote_item (
    podroll_id INTEGER NOT NULL REFERENCES channel_podroll(id) ON DELETE CASCADE
) INHERITS (remote_item_base);

--** MEDIUM

-- <podcast:medium>
CREATE TABLE medium_value (
    id SERIAL PRIMARY KEY,
    value TEXT UNIQUE CHECK (VALUE IN (
        'publisher',
        'podcast', 'music', 'video', 'film', 'audiobook', 'newsletter', 'blog', 'publisher', 'course',
        'mixed', 'podcastL', 'musicL', 'videoL', 'filmL', 'audiobookL', 'newsletterL', 'blogL', 'publisherL', 'courseL'
    ))
);

INSERT INTO medium_value (value) VALUES
    ('publisher'),
    ('podcast'), ('music'), ('video'), ('film'), ('audiobook'), ('newsletter'), ('blog'), ('course'),
    ('mixed'), ('podcastL'), ('musicL'), ('videoL'), ('filmL'), ('audiobookL'), ('newsletterL'), ('blogL'), ('publisherL'), ('courseL')
;

CREATE TABLE medium_base (
    id SERIAL PRIMARY KEY,
    medium_value_id INTEGER NOT NULL REFERENCES medium_value(id) ON DELETE CASCADE
);

CREATE TABLE channel_medium (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (medium_base);

CREATE TABLE remote_item_medium (
    remote_item_id INTEGER NOT NULL REFERENCES remote_item_base(id) ON DELETE CASCADE
) INHERITS (medium_base);

--** PERSON

-- <podcast:person>
CREATE TABLE person_base (
    id SERIAL PRIMARY KEY,
    name varchar_normal,
    role varchar_normal,
    person_group varchar_normal DEFAULT 'cast', -- group is a reserved keyword in sql
    img varchar_url,
    href varchar_url
);

CREATE TABLE channel_person (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (person_base);

CREATE TABLE item_person (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (person_base);

--** SOCIAL INTERACT

-- <podcast:socialInteract>
CREATE TABLE social_interact_base (
    id SERIAL PRIMARY KEY,
    protocol varchar_short NOT NULL,
    uri varchar_uri NOT NULL,
    account_id varchar_normal,
    account_url varchar_url,
    priority INTEGER
);

CREATE TABLE channel_social_interact (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (social_interact_base);

CREATE TABLE item_social_interact (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (social_interact_base);

--** TXT

-- <podcast:txt>
CREATE TABLE txt_tag_base (
    id SERIAL PRIMARY KEY,
    verify varchar_normal NOT NULL,
    value varchar_long NOT NULL
);

CREATE TABLE channel_txt_tag (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (txt_tag_base);

CREATE TABLE item_txt_tag (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (txt_tag_base);

--** VALUE TAG

-- <podcast:value>
CREATE TABLE value_tag_base (
    id SERIAL PRIMARY KEY,
    type varchar_short NOT NULL,
    method varchar_short NOT NULL,
    suggested numeric_20_11
);

CREATE TABLE channel_value_tag (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
) INHERITS (value_tag_base);

CREATE TABLE item_value_tag (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (value_tag_base);

--** VALUE TAG > RECEIPIENT

-- <podcast:valueRecipient>
CREATE TABLE value_tag_receipient (
    id SERIAL PRIMARY KEY,
    value_tag_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    address varchar_long NOT NULL,
    split numeric_20_11 NOT NULL,
    name varchar_normal,
    custom_key varchar_long,
    custom_value varchar_long,
    fee BOOLEAN DEFAULT FALSE
);

--** VALUE TAG > TIME SPLIT

-- <podcast:valueTimeSplit>
CREATE TABLE value_tag_time_split (
    id SERIAL PRIMARY KEY,
    value_tag_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    start_time INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    remote_start_time INTEGER DEFAULT 0,
    remote_percentage INTEGER DEFAULT 100
);

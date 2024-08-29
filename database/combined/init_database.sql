-- 0000 migration

-- Helpers

-- In the previous version of the app, short_id was 7-14 characters long.
-- To make migration to v2 easier, we will use a 15 character long short_id,
-- so we can easily distinguish between v1 and v2 short_ids.
CREATE DOMAIN short_id_v2 AS VARCHAR(15);

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

CREATE DOMAIN server_time AS TIMESTAMP;
CREATE DOMAIN server_time_with_default AS TIMESTAMP DEFAULT NOW();

CREATE DOMAIN media_player_time AS NUMERIC(10, 2);
CREATE DOMAIN list_position AS NUMERIC(22, 21);
CREATE DOMAIN numeric_20_11 AS NUMERIC(20, 11);

-- Function to set updated_at
CREATE OR REPLACE FUNCTION set_updated_at_field()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 0001 migration

/*

PODCASTING 2.0 DATABASE SCHEMA

- The `id` column is a SERIAL column that is used as the primary key for every table.

- The `id_text` column is only intended for tables where the data is available as urls.
  For example, https://podverse.fm/podcast/abc123def456, the `id_text` column would be `abc123def456`.

- The `slug` column is not required, but functions as an alternative for `id_text`.
  For example, https://podverse.fm/podcast/podcasting-20 would have a `slug` column with the value `podcasting-20`.

- The `podcast_index_id` ensures that our database only contains feed data that is available in the Podcast Index API.

*/

----------** GLOBAL REFERENCE TABLES **----------
-- These tables are referenced across many tables, and must be created first.

--** CATEGORY

-- Allowed category values align with the standard categories and subcategories
-- supported by Apple iTunes through the <itunes:category> tag.
-- 
CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    node_text varchar_normal NOT NULL, -- <itunes:category>
    display_name varchar_normal NOT NULL, -- our own display name for the category
    slug varchar_normal NOT NULL -- our own slug for the category
);

--** MEDIUM VALUE

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

----------** TABLES **----------

--** FEED > FLAG STATUS

-- used internally for identifying and handling spam and other special flag statuses.
CREATE TABLE feed_flag_status (
    id SERIAL PRIMARY KEY,
    status TEXT UNIQUE CHECK (status IN ('none', 'spam', 'takedown', 'other', 'always-allow')),
    created_at server_time_with_default,
    updated_at server_time_with_default
);

CREATE TRIGGER set_updated_at_feed_flag_status
BEFORE UPDATE ON feed_flag_status
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_field();

INSERT INTO feed_flag_status (status) VALUES ('none'), ('spam'), ('takedown'), ('other'), ('always-allow');

--** FEED

-- The top-level table for storing feed data, and internal parsing data.
CREATE TABLE feed (
    id SERIAL PRIMARY KEY,
    url varchar_url UNIQUE NOT NULL,

    -- feed flag
    feed_flag_status_id INTEGER NOT NULL REFERENCES feed_flag_status(id),

    -- internal

    -- Used to prevent another thread from parsing the same feed.
    -- Set to current time at beginning of parsing, and NULL at end of parsing. 
    -- This is to prevent multiple threads from parsing the same feed.
    -- If is_parsing is over X minutes old, assume last parsing failed and proceed to parse.
    is_parsing server_time,

    -- 0 will only be parsed when PI API reports an update.
    -- higher parsing_priority will be parsed more frequently on a schedule.
    parsing_priority INTEGER DEFAULT 0 CHECK (parsing_priority BETWEEN 0 AND 5),

    -- the run-time environment container id
    container_id VARCHAR(12),

    created_at server_time_with_default,
    updated_at server_time_with_default
);

CREATE TRIGGER set_updated_at_feed
BEFORE UPDATE ON feed
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_field();

CREATE TABLE feed_log (
    id SERIAL PRIMARY KEY,
    feed_id INTEGER NOT NULL REFERENCES feed(id) ON DELETE CASCADE,
    last_http_status INTEGER,
    last_crawl_time server_time,
    last_good_http_status_time server_time,
    last_parse_time server_time,
    last_update_time server_time,
    crawl_errors INTEGER DEFAULT 0,
    parse_errors INTEGER DEFAULT 0
);

--** CHANNEL

-- <channel>
CREATE TABLE channel (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    slug varchar_slug,
    feed_id INTEGER NOT NULL REFERENCES feed(id) ON DELETE CASCADE,
    podcast_index_id INTEGER UNIQUE NOT NULL,
    podcast_guid UUID UNIQUE, -- <podcast:guid>
    title varchar_normal,
    sortable_title varchar_short, -- all lowercase, ignores articles at beginning of title
    medium_value_id INTEGER REFERENCES medium_value(id),

    -- TODO: should we hash the last parsed feed, so we can compare it to the hash of
    -- a feed before completely parsing it, to check if it has changed before continuing?

    -- channels that have a PI value tag require special handling to request value data
    -- from the Podcast Index API.
    has_podcast_index_value BOOLEAN DEFAULT FALSE,

    -- hidden items are no longer available in the rss feed, but are still in the database.
    hidden BOOLEAN DEFAULT FALSE,
    -- markedForDeletion items are no longer available in the rss feed, and may be able to be deleted.
    marked_for_deletion BOOLEAN DEFAULT FALSE
);

CREATE UNIQUE INDEX channel_podcast_guid_unique ON channel(podcast_guid) WHERE podcast_guid IS NOT NULL;
CREATE UNIQUE INDEX channel_slug ON channel(slug) WHERE slug IS NOT NULL;

--** CHANNEL > ABOUT > ITUNES TYPE

-- <channel> -> <itunes:type>
CREATE TABLE channel_itunes_type (
    id SERIAL PRIMARY KEY,
    itunes_type TEXT UNIQUE CHECK (itunes_type IN ('episodic', 'serial'))
);

INSERT INTO channel_itunes_type (itunes_type) VALUES ('episodic'), ('serial');

--** CHANNEL > ABOUT

-- various <channel> child data from multiple tags
CREATE TABLE channel_about (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    author varchar_normal, -- <itunes:author> and <author>
    episode_count INTEGER, -- aggregated count for convenience
    explicit BOOLEAN, -- <itunes:explicit>
    itunes_type_id INTEGER REFERENCES channel_itunes_type(id),
    language varchar_short, -- <language>
    website_link_url varchar_url -- <link>
);

--** CHANNEL > CATEGORY

CREATE TABLE channel_category (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES channel_category(id) ON DELETE CASCADE
);

--** CHANNEL > CHAT

-- <channel> -> <podcast:chat>
CREATE TABLE channel_chat (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    server varchar_fqdn NOT NULL,
    protocol varchar_short,
    account_id varchar_normal,
    space varchar_normal
);

--** CHANNEL > DESCRIPTION

-- <channel> -> <description> AND possibly other tags that contain a description
CREATE TABLE channel_description (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    UNIQUE (channel_id),
    value varchar_long NOT NULL
);

--** CHANNEL > FUNDING

-- <channel> -> <podcast:funding>
CREATE TABLE channel_funding (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    title varchar_normal
);

--** CHANNEL > IMAGE

-- <channel> -> <podcast:image> AND all other image tags in the rss feed
CREATE TABLE channel_image (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    image_width_size INTEGER, -- <podcast:image> must have a width specified, but older image tags will not, so allow null.

    -- If true, then the image is hosted by us in a service like S3.
    -- When is_resized images are deleted, the corresponding image in S3
    -- should also be deleted.
    is_resized BOOLEAN DEFAULT FALSE
);

--** CHANNEL > INTERNAL SETTINGS

CREATE TABLE channel_internal_settings (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    -- needed to approve which web domains can override the player with query params.
    -- this prevents malicious parties from misrepresenting the podcast contents on another website.
    embed_approved_media_url_paths TEXT
);

--** CHANNEL > LICENSE

-- <channel> -> <podcast:license>
CREATE TABLE channel_license (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    UNIQUE (channel_id),
    identifier varchar_normal NOT NULL,
    url varchar_url
);

--** CHANNEL > LOCATION

-- <channel> -> <podcast:location>
CREATE TABLE channel_location (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    geo varchar_normal,
    osm varchar_normal,
    CHECK (geo IS NOT NULL OR osm IS NOT NULL),
    name varchar_normal
);

--** CHANNEL > PERSON

-- <channel> -> <podcast:person>
CREATE TABLE channel_person (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    name varchar_normal NOT NULL,
    role varchar_normal,
    person_group varchar_normal DEFAULT 'cast', -- group is a reserved keyword in sql
    img varchar_url,
    href varchar_url
);

--** CHANNEL > PODROLL

-- <channel> -> <podcast:podroll>
CREATE TABLE channel_podroll (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
);

--** CHANNEL > PODROLL > REMOTE ITEM

-- <channel> -> <podcast:podroll> --> <podcast:remoteItem>
CREATE TABLE channel_podroll_remote_item (
    id SERIAL PRIMARY KEY,
    channel_podroll_id INTEGER NOT NULL REFERENCES channel_podroll(id) ON DELETE CASCADE,
    feed_guid UUID NOT NULL,
    feed_url varchar_url,
    item_guid varchar_uri,
    title varchar_normal,
    medium_value_id INTEGER REFERENCES medium_value(id)
);

--** CHANNEL > PUBLISHER

-- <channel> -> <podcast:publisher>
CREATE TABLE channel_publisher (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE
);

--** CHANNEL > PUBLISHER > REMOTE ITEM

-- <channel> -> <podcast:publisher> -> <podcast:remoteItem>
CREATE TABLE channel_publisher_remote_item (
    id SERIAL PRIMARY KEY,
    channel_publisher_id INTEGER NOT NULL REFERENCES channel_publisher(id) ON DELETE CASCADE,
    feed_guid UUID NOT NULL,
    feed_url varchar_url,
    item_guid varchar_uri,
    title varchar_normal,
    medium_value_id INTEGER REFERENCES medium_value(id)
);

--** CHANNEL > REMOTE ITEM

-- Remote items at the channel level are only used when the <podcast:medium> for the channel
-- is set to 'mixed' or another list medium like 'podcastL'.

-- <channel> -> <podcast:remoteItem>
CREATE TABLE channel_remote_item (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    feed_guid UUID NOT NULL,
    feed_url varchar_url,
    item_guid varchar_uri,
    title varchar_normal,
    medium_value_id INTEGER REFERENCES medium_value(id)
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

--** CHANNEL > SOCIAL INTERACT

-- <channel> -> <podcast:socialInteract>
CREATE TABLE channel_social_interact (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    protocol varchar_short NOT NULL,
    uri varchar_uri NOT NULL,
    account_id varchar_normal,
    account_url varchar_url,
    priority INTEGER
);

--** CHANNEL > TRAILER

-- <channel> -> <podcast:trailer>
CREATE TABLE channel_trailer (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    title varchar_normal,
    pubdate TIMESTAMPTZ NOT NULL,
    length INTEGER,
    type varchar_short,
    season INTEGER,
    UNIQUE (channel_id, url)
);

--** CHANNEL > TXT

-- <channel> -> <podcast:txt>
CREATE TABLE channel_txt (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    purpose varchar_normal,
    value varchar_long NOT NULL
);

--** CHANNEL > VALUE

-- <channel> -> <podcast:value>
CREATE TABLE channel_value (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    method varchar_short NOT NULL,
    suggested FLOAT
);

--** CHANNEL > VALUE > RECEIPIENT

-- <channel> -> <podcast:value> -> <podcast:valueRecipient>
CREATE TABLE channel_value_receipient (
    id SERIAL PRIMARY KEY,
    channel_value_id INTEGER NOT NULL REFERENCES channel_value(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    address varchar_long NOT NULL,
    split FLOAT NOT NULL,
    name varchar_normal,
    custom_key varchar_long,
    custom_value varchar_long,
    fee BOOLEAN DEFAULT FALSE
);

--** ITEM

-- Technically the item table could be named channel_item, but it seems easier to understand as item.

-- <channel> -> <item>
CREATE TABLE item (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    slug varchar_slug,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    guid varchar_uri, -- <guid>
    pubdate TIMESTAMPTZ, -- <pubDate>
    title varchar_normal, -- <title>

    -- hidden items are no longer available in the rss feed, but are still in the database.
    hidden BOOLEAN DEFAULT FALSE,
    -- markedForDeletion items are no longer available in the rss feed, and may be able to be deleted.
    marked_for_deletion BOOLEAN DEFAULT FALSE
);

CREATE UNIQUE INDEX item_slug ON item(slug) WHERE slug IS NOT NULL;

--** ITEM > ABOUT > ITUNES TYPE

-- <item> -> <itunes:episodeType>
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
    item_itunes_episode_type_id INTEGER REFERENCES item_itunes_episode_type(id) -- <itunes:episodeType>
);

--** ITEM > CHAPTERS

-- <item> -> <podcast:chapters>
CREATE TABLE item_chapters (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    type varchar_short NOT NULL,
    last_http_status INTEGER,
    last_crawl_time server_time,
    last_good_http_status_time server_time,
    last_parse_time server_time,
    last_update_time server_time,
    crawl_errors INTEGER DEFAULT 0,
    parse_errors INTEGER DEFAULT 0
);

-- -- <item> -> <podcast:chapters> -> chapter items correspond with jsonChapters.md example file
CREATE TABLE item_chapter (
    id SERIAL PRIMARY KEY,
    text_id short_id_v2 UNIQUE NOT NULL,
    item_chapters_file_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,

    -- the hash is used for comparison, to determine if new chapters should be inserted
    -- after re-parsing an existing chapters file. 
    hash varchar_guid NOT NULL,

    start_time media_player_time NOT NULL,
    end_time media_player_time,
    title varchar_normal,
    web_url varchar_url,
    table_of_contents BOOLEAN DEFAULT TRUE
);

--** ITEM > CHAPTER > IMAGE

-- <item> -> <podcast:chapters> -> chapter items correspond with jsonChapters.md example file
CREATE TABLE item_chapter_image (
    id SERIAL PRIMARY KEY,
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    image_width_size INTEGER, -- <podcast:image> must have a width specified, but older image tags will not, so allow null.

    -- If true, then the image is hosted by us in a service like S3.
    -- When is_resized images are deleted, the corresponding image in S3
    -- should also be deleted.
    is_resized BOOLEAN DEFAULT FALSE
);

--** ITEM > CHAPTER > LOCATION

-- <item> -> <podcast:chapters> -> chapter items correspond with jsonChapters.md example file
CREATE TABLE item_chapter_location (
    id SERIAL PRIMARY KEY,
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE,
    geo varchar_normal,
    osm varchar_normal,
    CHECK (geo IS NOT NULL OR osm IS NOT NULL),
    name varchar_normal
);

--** ITEM > CHAT

-- <item> -> <podcast:chat>
CREATE TABLE item_chat (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    server varchar_fqdn NOT NULL,
    protocol varchar_short,
    account_id varchar_normal,
    space varchar_normal
);

--** ITEM > CONTENT LINK

-- <item> -> <podcast:contentLink>
CREATE TABLE item_content_link (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    href varchar_url NOT NULL,
    title varchar_normal
);

--** ITEM > DESCRIPTION

-- <item> -> <description> AND possibly other tags that contain a description
CREATE TABLE item_description (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    UNIQUE (item_id),
    value varchar_long NOT NULL
);

--** ITEM > ENCLOSURE (AKA ALTERNATE ENCLOSURE)

-- NOTE: the older <enclosure> tag style is integrated into the item_enclosure table.

-- <item> -> <podcast:alternateEnclosure> AND <item> -> <enclosure>
CREATE TABLE item_enclosure (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    length INTEGER,
    bitrate INTEGER,
    height INTEGER,
    language varchar_short,
    title varchar_short,
    rel varchar_short,
    codecs varchar_short,
    item_enclosure_default BOOLEAN DEFAULT FALSE
);

-- <item> -> <podcast:alternateEnclosure> -> <podcast:source>
CREATE TABLE item_enclosure_source (
    id SERIAL PRIMARY KEY,
    item_enclosure_id INTEGER NOT NULL REFERENCES item_enclosure(id) ON DELETE CASCADE,
    uri varchar_uri NOT NULL,
    content_type varchar_short
);

-- <item> -> <podcast:alternateEnclosure> -> <podcast:integrity>
CREATE TABLE item_enclosure_integrity (
    id SERIAL PRIMARY KEY,
    item_enclosure_id INTEGER NOT NULL REFERENCES item_enclosure_source(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('sri', 'pgp-signature')),
    value varchar_long NOT NULL
);

--** ITEM > FUNDING

-- <item> -> <podcast:funding>
CREATE TABLE item_funding (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    title varchar_normal
);

--** ITEM > IMAGE

-- <item> -> <podcast:image> AND all other image tags in the rss feed
CREATE TABLE item_image (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    image_width_size INTEGER, -- <podcast:image> must have a width specified, but older image tags will not, so allow null.

    -- If true, then the image is hosted by us in a service like S3.
    -- When is_resized images are deleted, the corresponding image in S3
    -- should also be deleted.
    is_resized BOOLEAN DEFAULT FALSE
);

--** ITEM > LICENSE

-- <item> -> <podcast:license>
CREATE TABLE item_license (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    UNIQUE (item_id),
    identifier varchar_normal NOT NULL,
    url varchar_url
);

--** ITEM > LOCATION

-- <item> -> <podcast:location>
CREATE TABLE item_location (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    geo varchar_normal,
    osm varchar_normal,
    CHECK (geo IS NOT NULL OR osm IS NOT NULL),
    name varchar_normal
);

--** ITEM > PERSON

-- <item> -> <podcast:person>
CREATE TABLE item_person (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    name varchar_normal NOT NULL,
    role varchar_normal,
    person_group varchar_normal DEFAULT 'cast', -- group is a reserved keyword in sql
    img varchar_url,
    href varchar_url
);

--** ITEM > SEASON

-- <item> -> <podcast:season>
CREATE TABLE item_season (
    id SERIAL PRIMARY KEY,
    channel_season_id INTEGER NOT NULL REFERENCES channel_season(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    title varchar_normal
);

--** ITEM > SEASON > EPISODE

-- <item> -> <podcast:season> -> <podcast:episode>
CREATE TABLE item_season_episode (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    display varchar_short,
    episode_number FLOAT NOT NULL
);

--** ITEM > SOCIAL INTERACT

-- <item> -> <podcast:socialInteract>
CREATE TABLE item_social_interact (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    protocol varchar_short NOT NULL,
    uri varchar_uri NOT NULL,
    account_id varchar_normal,
    account_url varchar_url,
    priority INTEGER
);

--** ITEM > SOUNDBITE

-- <item> -> <podcast:soundbite>
CREATE TABLE item_soundbite (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    start_time INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    title varchar_normal
);

--** ITEM > TRANSCRIPT

-- <item> -> <podcast:transcript>
CREATE TABLE item_transcript (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    type varchar_short NOT NULL,
    language varchar_short,
    rel VARCHAR(50) CHECK (rel IS NULL OR rel = 'captions')
);

--** ITEM > TXT

-- <item> -> <podcast:txt>
CREATE TABLE item_txt (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    purpose varchar_normal,
    value varchar_long NOT NULL
);

--** ITEM > VALUE

-- <item> -> <podcast:value>
CREATE TABLE item_value (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    method varchar_short NOT NULL,
    suggested FLOAT
);

--** ITEM > VALUE > RECEIPIENT

-- <item> -> <podcast:value> -> <podcast:valueRecipient>
CREATE TABLE item_value_receipient (
    id SERIAL PRIMARY KEY,
    item_value_id INTEGER NOT NULL REFERENCES item_value(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    address varchar_long NOT NULL,
    split FLOAT NOT NULL,
    name varchar_normal,
    custom_key varchar_long,
    custom_value varchar_long,
    fee BOOLEAN DEFAULT FALSE
);

--** ITEM > VALUE > TIME SPLIT

-- <item> -> <podcast:value> -> <podcast:valueTimeSplit>
CREATE TABLE item_value_time_split (
    id SERIAL PRIMARY KEY,
    item_value_id INTEGER NOT NULL REFERENCES item_value(id) ON DELETE CASCADE,
    start_time INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    remote_start_time INTEGER DEFAULT 0,
    remote_percentage INTEGER DEFAULT 100
);

--** ITEM > VALUE > TIME SPLIT > REMOTE ITEM

-- <item> -> <podcast:value> -> <podcast:valueTimeSplit> -> <podcast:remoteItem>
CREATE TABLE item_value_time_split_remote_item (
    id SERIAL PRIMARY KEY,
    item_value_time_split_id INTEGER NOT NULL REFERENCES item_value_time_split(id) ON DELETE CASCADE,
    feed_guid UUID NOT NULL,
    feed_url varchar_url,
    item_guid varchar_uri,
    title varchar_normal
);

--** ITEM > VALUE > TIME SPLIT > VALUE RECIPEINT

-- <item> -> <podcast:value> -> <podcast:valueTimeSplit> -> <podcast:valueRecipient>
CREATE TABLE item_value_time_split_receipient (
    id SERIAL PRIMARY KEY,
    item_value_time_split_id INTEGER NOT NULL REFERENCES item_value_time_split(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    address varchar_long NOT NULL,
    split FLOAT NOT NULL,
    name varchar_normal,
    custom_key varchar_long,
    custom_value varchar_long,
    fee BOOLEAN DEFAULT FALSE
);

--** LIVE ITEM > STATUS

CREATE TABLE live_item_status (
    id SERIAL PRIMARY KEY,
    status TEXT UNIQUE CHECK (status IN ('pending', 'live', 'ended'))
);

INSERT INTO live_item_status (status) VALUES ('pending'), ('live'), ('ended');

--** LIVE ITEM

-- Technically the live_item table could be named channel_live_item,
-- but for consistency with the item table, it is called live_item.

-- <channel> -> <podcast:liveItem>
CREATE TABLE live_item (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    live_item_status_id INTEGER NOT NULL REFERENCES live_item_status(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    chat_web_url varchar_url
);


-- 0002 migration

CREATE TABLE sharable_status (
    id SERIAL PRIMARY KEY,
    status TEXT UNIQUE CHECK (status IN ('public', 'unlisted', 'private'))
);

INSERT INTO sharable_status (status) VALUES ('public'), ('unlisted'), ('private');

CREATE TABLE account (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id)
);

CREATE TABLE account_credentials (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    email varchar_email UNIQUE NOT NULL,
    password varchar_password NOT NULL
);

CREATE TABLE account_profile (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    display_name varchar_normal,
    bio varchar_long
);

CREATE TABLE account_reset_password (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    reset_token varchar_guid,
    reset_token_expires_at TIMESTAMP
);

CREATE TABLE account_verification (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    verification_token varchar_guid,
    verification_token_expires_at TIMESTAMP
);

CREATE TABLE account_membership (
    id SERIAL PRIMARY KEY,
    tier TEXT UNIQUE CHECK (tier IN ('trial', 'basic'))
);

INSERT INTO account_membership (tier) VALUES ('trial'), ('basic');

CREATE TABLE account_membership_status (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    account_membership_id INTEGER NOT NULL REFERENCES account_membership(id),
    membership_expires_at TIMESTAMP
);

CREATE TABLE account_admin_roles (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    dev_admin BOOLEAN DEFAULT FALSE,
    podping_admin BOOLEAN DEFAULT FALSE
);

-- 0003 migration

CREATE TABLE clip (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    start_time media_player_time NOT NULL,
    end_time media_player_time,
    title varchar_normal,
    description varchar_long,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id)
);

-- 0004 migration

CREATE TABLE playlist (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id),
    title varchar_normal,
    description varchar_long,
    is_default_favorites BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT FALSE,
    item_count INTEGER DEFAULT 0,
    medium_value_id INTEGER NOT NULL REFERENCES medium_value(id)
);

CREATE TABLE playlist_resource_base (
    id SERIAL PRIMARY KEY,
    playlist_id INTEGER NOT NULL REFERENCES playlist(id) ON DELETE CASCADE,
    list_position list_position NOT NULL CHECK (list_position != 0 OR list_position = 0::numeric),
    UNIQUE (playlist_id, list_position)
);

CREATE TABLE playlist_resource_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE TABLE playlist_resource_item_add_by_rss (
    resource_data jsonb NOT NULL
) INHERITS (playlist_resource_base);

CREATE TABLE playlist_resource_item_chapter (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE TABLE playlist_resource_clip (
    clip_id INTEGER NOT NULL REFERENCES clip(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE TABLE playlist_resource_item_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE OR REPLACE FUNCTION delete_playlist_resource_base()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM playlist_resource_base WHERE id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_playlist_resource_base_trigger_item
BEFORE DELETE ON playlist_resource_item
FOR EACH ROW
EXECUTE FUNCTION delete_playlist_resource_base();

CREATE TRIGGER delete_playlist_resource_base_trigger_item_add_by_rss
BEFORE DELETE ON playlist_resource_item_add_by_rss
FOR EACH ROW
EXECUTE FUNCTION delete_playlist_resource_base();

CREATE TRIGGER delete_playlist_resource_base_trigger_item_chapter
BEFORE DELETE ON playlist_resource_item_chapter
FOR EACH ROW
EXECUTE FUNCTION delete_playlist_resource_base();

CREATE TRIGGER delete_playlist_resource_base_trigger_clip
BEFORE DELETE ON playlist_resource_clip
FOR EACH ROW
EXECUTE FUNCTION delete_playlist_resource_base();

CREATE TRIGGER delete_playlist_resource_base_trigger_item_soundbite
BEFORE DELETE ON playlist_resource_item_soundbite
FOR EACH ROW
EXECUTE FUNCTION delete_playlist_resource_base();

-- 0005 migration

CREATE TABLE queue (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    medium_value_id INTEGER NOT NULL REFERENCES medium_value(id),
    UNIQUE (account_id, medium_value_id)
);

CREATE TABLE queue_resource_base (
    id SERIAL PRIMARY KEY,
    queue_id INTEGER NOT NULL REFERENCES queue(id) ON DELETE CASCADE,
    UNIQUE (queue_id, list_position),
    list_position list_position NOT NULL CHECK (list_position != 0 OR list_position = 0::numeric),
    playback_position media_player_time NOT NULL DEFAULT 0,
    media_file_duration FLOAT NOT NULL DEFAULT 0,
    completed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE queue_resource_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE TABLE queue_resource_item_add_by_rss (
    resource_data jsonb NOT NULL,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE TABLE queue_resource_item_chapter (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE TABLE queue_resource_clip (
    clip_id INTEGER NOT NULL REFERENCES clip(id) ON DELETE CASCADE,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE TABLE queue_resource_item_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE OR REPLACE FUNCTION delete_queue_resource_base()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM queue_resource_base WHERE id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_queue_resource_base_trigger_item
BEFORE DELETE ON queue_resource_item
FOR EACH ROW
EXECUTE FUNCTION delete_queue_resource_base();

CREATE TRIGGER delete_queue_resource_base_trigger_item_add_by_rss
BEFORE DELETE ON queue_resource_item_add_by_rss
FOR EACH ROW
EXECUTE FUNCTION delete_queue_resource_base();

CREATE TRIGGER delete_queue_resource_base_trigger_item_chapter
BEFORE DELETE ON queue_resource_item_chapter
FOR EACH ROW
EXECUTE FUNCTION delete_queue_resource_base();

CREATE TRIGGER delete_queue_resource_base_trigger_clip
BEFORE DELETE ON queue_resource_clip
FOR EACH ROW
EXECUTE FUNCTION delete_queue_resource_base();

CREATE TRIGGER delete_queue_resource_base_trigger_item_soundbite
BEFORE DELETE ON queue_resource_item_soundbite
FOR EACH ROW
EXECUTE FUNCTION delete_queue_resource_base();

-- 0006 migration

CREATE TABLE account_following_account (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    following_account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, following_account_id)
);

CREATE TABLE account_following_channel (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, channel_id)
);

CREATE TABLE account_following_playlist (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    playlist_id INTEGER NOT NULL REFERENCES playlist(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, playlist_id)
);

CREATE TABLE account_following_add_by_rss_channel (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    feed_url varchar_url NOT NULL,
    PRIMARY KEY (account_id, feed_url),
    title varchar_normal,
    image_url varchar_url
);

-- 0007

CREATE TABLE account_notification (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    PRIMARY KEY (channel_id, account_id)
);

CREATE TABLE account_up_device (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    up_endpoint varchar_url PRIMARY KEY,
    up_public_key varchar_long NOT NULL,
    up_auth_key varchar_long NOT NULL
);

CREATE DOMAIN varchar_fcm_token AS VARCHAR(255);

CREATE TABLE account_fcm_device (
    fcm_token varchar_fcm_token PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE
);

-- 0008

CREATE TABLE account_paypal_order (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    payment_id VARCHAR PRIMARY KEY,
    state VARCHAR
);

CREATE TABLE account_app_store_purchase (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    transaction_id VARCHAR PRIMARY KEY,
    cancellation_date VARCHAR,
    cancellation_date_ms VARCHAR,
    cancellation_date_pst VARCHAR,
    cancellation_reason VARCHAR,
    expires_date VARCHAR,
    expires_date_ms VARCHAR,
    expires_date_pst VARCHAR,
    is_in_intro_offer_period BOOLEAN,
    is_trial_period BOOLEAN,
    original_purchase_date VARCHAR,
    original_purchase_date_ms VARCHAR,
    original_purchase_date_pst VARCHAR,
    original_transaction_id VARCHAR,
    product_id VARCHAR,
    promotional_offer_id VARCHAR,
    purchase_date VARCHAR,
    purchase_date_ms VARCHAR,
    purchase_date_pst VARCHAR,
    quantity INT,
    web_order_line_item_id VARCHAR
);

CREATE TABLE account_google_play_purchase (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    transaction_id VARCHAR PRIMARY KEY,
    acknowledgement_state INT NULL,
    consumption_state INT NULL,
    developer_payload VARCHAR NULL,
    kind VARCHAR NULL,
    product_id VARCHAR NOT NULL,
    purchase_time_millis VARCHAR NULL,
    purchase_state INT NULL,
    purchase_token VARCHAR UNIQUE NOT NULL
);


-- 0009

CREATE TABLE membership_claim_token (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claimed BOOLEAN DEFAULT FALSE,
    years_to_add INT DEFAULT 1,
    account_membership_id INT REFERENCES account_membership(id) ON DELETE CASCADE
);


-- 0000 migration

-- Helpers

-- START CREATE read AND read_write users

-- Create the "read" user
CREATE USER read WITH PASSWORD 'your_read_password';

-- Create the "read_write" user
CREATE USER read_write WITH PASSWORD 'your_read_write_password';

-- Grant CONNECT and USAGE privileges on the database and schema to both users
GRANT CONNECT ON DATABASE postgres TO read, read_write;
GRANT USAGE ON SCHEMA public TO read, read_write;

-- Grant SELECT privileges on all tables and sequences to the "read" user
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO read;

-- Grant SELECT, INSERT, UPDATE, DELETE privileges on all tables to the "read_write" user
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO read_write;
GRANT SELECT, USAGE, UPDATE ON ALL SEQUENCES IN SCHEMA public TO read_write;

-- Ensure future tables and sequences have the correct privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO read;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO read;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO read_write;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, USAGE, UPDATE ON SEQUENCES TO read_write;

-- END CREATE read AND read_write users

-- In the previous version of the app, short_id was 7-14 characters long.
-- To make migration to v2 easier, we will use a 15 character long short_id,
-- so we can easily distinguish between v1 and v2 short_ids.
CREATE DOMAIN short_id_v2 AS VARCHAR(15);

CREATE DOMAIN varchar_short AS VARCHAR(50);
CREATE DOMAIN varchar_normal AS VARCHAR(255);
CREATE DOMAIN varchar_long AS VARCHAR(2500);

CREATE DOMAIN varchar_email AS VARCHAR(255) CHECK (VALUE ~ '^.+@.+\..+$');
CREATE DOMAIN varchar_fcm_token AS VARCHAR(255);
CREATE DOMAIN varchar_fqdn AS VARCHAR(253);
CREATE DOMAIN varchar_guid AS VARCHAR(36);
CREATE DOMAIN varchar_md5 AS VARCHAR(32);
-- bcrypt salted hash passwords are always 60 characters long
CREATE DOMAIN varchar_password AS VARCHAR(60);
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
    parent_id INTEGER REFERENCES category(id) ON DELETE CASCADE,
    display_name varchar_normal NOT NULL, -- our own display name for the category
    slug varchar_normal NOT NULL, -- our own web url slug for the category
    mapping_key varchar_normal NOT NULL -- camel case version of the slug
);

CREATE INDEX idx_category_parent_id ON category(parent_id);

-- Insert parent categories
INSERT INTO category (parent_id, display_name, slug, mapping_key) VALUES
(NULL, 'Arts', 'arts', 'arts'),
(NULL, 'Business', 'business', 'business'),
(NULL, 'Comedy', 'comedy', 'comedy'),
(NULL, 'Education', 'education', 'education'),
(NULL, 'Fiction', 'fiction', 'fiction'),
(NULL, 'Government', 'government', 'government'),
(NULL, 'History', 'history', 'history'),
(NULL, 'Health & Fitness', 'health-and-fitness', 'healthandfitness'),
(NULL, 'Kids & Family', 'kids-and-family', 'kidsandfamily'),
(NULL, 'Leisure', 'leisure', 'leisure'),
(NULL, 'Music', 'music', 'music'),
(NULL, 'News', 'news', 'news'),
(NULL, 'Religion & Spirituality', 'religion-and-spirituality', 'religionandspirituality'),
(NULL, 'Science', 'science', 'science'),
(NULL, 'Society & Culture', 'society-and-culture', 'societyandculture'),
(NULL, 'Sports', 'sports', 'sports'),
(NULL, 'Technology', 'technology', 'technology'),
(NULL, 'True Crime', 'true-crime', 'truecrime'),
(NULL, 'TV & Film', 'tv-and-film', 'tvandfilm');

-- Insert child categories
INSERT INTO category (parent_id, display_name, slug, mapping_key) VALUES
((SELECT id FROM category WHERE display_name = 'Arts'), 'Books', 'books', 'books'),
((SELECT id FROM category WHERE display_name = 'Arts'), 'Design', 'design', 'design'),
((SELECT id FROM category WHERE display_name = 'Arts'), 'Fashion & Beauty', 'fashion-and-beauty', 'fashionandbeauty'),
((SELECT id FROM category WHERE display_name = 'Arts'), 'Food', 'food', 'food'),
((SELECT id FROM category WHERE display_name = 'Arts'), 'Performing Arts', 'performing-arts', 'performingarts'),
((SELECT id FROM category WHERE display_name = 'Arts'), 'Visual Arts', 'visual-arts', 'visualarts'),
((SELECT id FROM category WHERE display_name = 'Business'), 'Careers', 'careers', 'careers'),
((SELECT id FROM category WHERE display_name = 'Business'), 'Entrepreneurship', 'entrepreneurship', 'entrepreneurship'),
((SELECT id FROM category WHERE display_name = 'Business'), 'Investing', 'investing', 'investing'),
((SELECT id FROM category WHERE display_name = 'Business'), 'Management', 'management', 'management'),
((SELECT id FROM category WHERE display_name = 'Business'), 'Marketing', 'marketing', 'marketing'),
((SELECT id FROM category WHERE display_name = 'Business'), 'Non-Profit', 'non-profit', 'nonprofit'),
((SELECT id FROM category WHERE display_name = 'Comedy'), 'Comedy Interviews', 'comedy-interviews', 'comedyinterviews'),
((SELECT id FROM category WHERE display_name = 'Comedy'), 'Improv', 'improv', 'improv'),
((SELECT id FROM category WHERE display_name = 'Comedy'), 'Stand-Up', 'stand-up', 'standup'),
((SELECT id FROM category WHERE display_name = 'Education'), 'Courses', 'courses', 'courses'),
((SELECT id FROM category WHERE display_name = 'Education'), 'How To', 'how-to', 'howto'),
((SELECT id FROM category WHERE display_name = 'Education'), 'Language Learning', 'language-learning', 'languagelearning'),
((SELECT id FROM category WHERE display_name = 'Education'), 'Self-Improvement', 'self-improvement', 'selfimprovement'),
((SELECT id FROM category WHERE display_name = 'Fiction'), 'Comedy Fiction', 'comedy-fiction', 'comedyfiction'),
((SELECT id FROM category WHERE display_name = 'Fiction'), 'Drama', 'drama', 'drama'),
((SELECT id FROM category WHERE display_name = 'Fiction'), 'Science Fiction', 'science-fiction', 'sciencefiction'),
((SELECT id FROM category WHERE display_name = 'Health & Fitness'), 'Alternative Health', 'alternative-health', 'alternativehealth'),
((SELECT id FROM category WHERE display_name = 'Health & Fitness'), 'Fitness', 'fitness', 'fitness'),
((SELECT id FROM category WHERE display_name = 'Health & Fitness'), 'Medicine', 'medicine', 'medicine'),
((SELECT id FROM category WHERE display_name = 'Health & Fitness'), 'Mental Health', 'mental-health', 'mentalhealth'),
((SELECT id FROM category WHERE display_name = 'Health & Fitness'), 'Nutrition', 'nutrition', 'nutrition'),
((SELECT id FROM category WHERE display_name = 'Health & Fitness'), 'Sexuality', 'sexuality', 'sexuality'),
((SELECT id FROM category WHERE display_name = 'Kids & Family'), 'Education for Kids', 'education-for-kids', 'educationforkids'),
((SELECT id FROM category WHERE display_name = 'Kids & Family'), 'Parenting', 'parenting', 'parenting'),
((SELECT id FROM category WHERE display_name = 'Kids & Family'), 'Pets & Animals', 'pets-and-animals', 'petsandanimals'),
((SELECT id FROM category WHERE display_name = 'Kids & Family'), 'Stories for Kids', 'stories-for-kids', 'storiesforkids'),
((SELECT id FROM category WHERE display_name = 'Leisure'), 'Animation & Manga', 'animation-and-manga', 'animationandmanga'),
((SELECT id FROM category WHERE display_name = 'Leisure'), 'Automotive', 'automotive', 'automotive'),
((SELECT id FROM category WHERE display_name = 'Leisure'), 'Aviation', 'aviation', 'aviation'),
((SELECT id FROM category WHERE display_name = 'Leisure'), 'Crafts', 'crafts', 'crafts'),
((SELECT id FROM category WHERE display_name = 'Leisure'), 'Games', 'games', 'games'),
((SELECT id FROM category WHERE display_name = 'Leisure'), 'Hobbies', 'hobbies', 'hobbies'),
((SELECT id FROM category WHERE display_name = 'Leisure'), 'Home & Garden', 'home-and-garden', 'homeandgarden'),
((SELECT id FROM category WHERE display_name = 'Leisure'), 'Video Games', 'video-games', 'videogames'),
((SELECT id FROM category WHERE display_name = 'Music'), 'Music Commentary', 'music-commentary', 'musiccommentary'),
((SELECT id FROM category WHERE display_name = 'Music'), 'Music History', 'music-history', 'musichistory'),
((SELECT id FROM category WHERE display_name = 'Music'), 'Music Interviews', 'music-interviews', 'musicinterviews'),
((SELECT id FROM category WHERE display_name = 'News'), 'Business News', 'business-news', 'businessnews'),
((SELECT id FROM category WHERE display_name = 'News'), 'Daily News', 'daily-news', 'dailynews'),
((SELECT id FROM category WHERE display_name = 'News'), 'Entertainment News', 'entertainment-news', 'entertainmentnews'),
((SELECT id FROM category WHERE display_name = 'News'), 'News Commentary', 'news-commentary', 'newscommentary'),
((SELECT id FROM category WHERE display_name = 'News'), 'Politics', 'politics', 'politics'),
((SELECT id FROM category WHERE display_name = 'News'), 'Sports News', 'sports-news', 'sportsnews'),
((SELECT id FROM category WHERE display_name = 'News'), 'Tech News', 'tech-news', 'technews'),
((SELECT id FROM category WHERE display_name = 'Religion & Spirituality'), 'Buddhism', 'buddhism', 'buddhism'),
((SELECT id FROM category WHERE display_name = 'Religion & Spirituality'), 'Christianity', 'christianity', 'christianity'),
((SELECT id FROM category WHERE display_name = 'Religion & Spirituality'), 'Hinduism', 'hinduism', 'hinduism'),
((SELECT id FROM category WHERE display_name = 'Religion & Spirituality'), 'Islam', 'islam', 'islam'),
((SELECT id FROM category WHERE display_name = 'Religion & Spirituality'), 'Judaism', 'judaism', 'judaism'),
((SELECT id FROM category WHERE display_name = 'Religion & Spirituality'), 'Religion', 'religion', 'religion'),
((SELECT id FROM category WHERE display_name = 'Religion & Spirituality'), 'Spirituality', 'spirituality', 'spirituality'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Astronomy', 'astronomy', 'astronomy'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Chemistry', 'chemistry', 'chemistry'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Earth Sciences', 'earth-sciences', 'earthsciences'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Life Sciences', 'life-sciences', 'lifesciences'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Mathematics', 'mathematics', 'mathematics'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Natural Sciences', 'natural-sciences', 'naturalsciences'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Nature', 'nature', 'nature'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Physics', 'physics', 'physics'),
((SELECT id FROM category WHERE display_name = 'Science'), 'Social Sciences', 'social-sciences', 'socialsciences'),
((SELECT id FROM category WHERE display_name = 'Society & Culture'), 'Documentary', 'documentary', 'documentary'),
((SELECT id FROM category WHERE display_name = 'Society & Culture'), 'Personal Journals', 'personal-journals', 'personaljournals'),
((SELECT id FROM category WHERE display_name = 'Society & Culture'), 'Philosophy', 'philosophy', 'philosophy'),
((SELECT id FROM category WHERE display_name = 'Society & Culture'), 'Places & Travel', 'places-and-travel', 'placesandtravel'),
((SELECT id FROM category WHERE display_name = 'Society & Culture'), 'Relationships', 'relationships', 'relationships'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Baseball', 'baseball', 'baseball'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Basketball', 'basketball', 'basketball'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Cricket', 'cricket', 'cricket'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Fantasy Sports', 'fantasy-sports', 'fantasysports'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Football', 'football', 'football'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Golf', 'golf', 'golf'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Hockey', 'hockey', 'hockey'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Rugby', 'rugby', 'rugby'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Running', 'running', 'running'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Soccer', 'soccer', 'soccer'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Swimming', 'swimming', 'swimming'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Tennis', 'tennis', 'tennis'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Volleyball', 'volleyball', 'volleyball'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Wilderness', 'wilderness', 'wilderness'),
((SELECT id FROM category WHERE display_name = 'Sports'), 'Wrestling', 'wrestling', 'wrestling'),
((SELECT id FROM category WHERE display_name = 'TV & Film'), 'After Shows', 'after-shows', 'aftershows'),
((SELECT id FROM category WHERE display_name = 'TV & Film'), 'Film History', 'film-history', 'filmhistory'),
((SELECT id FROM category WHERE display_name = 'TV & Film'), 'Film Interviews', 'film-interviews', 'filminterviews'),
((SELECT id FROM category WHERE display_name = 'TV & Film'), 'Film Reviews', 'film-reviews', 'filmreviews'),
((SELECT id FROM category WHERE display_name = 'TV & Film'), 'TV Reviews', 'tv-reviews', 'tvreviews');

--** MEDIUM VALUE

-- <podcast:medium>
CREATE TABLE medium (
    id SERIAL PRIMARY KEY,
    value TEXT UNIQUE CHECK (VALUE IN (
        'publisher',
        'podcast', 'music', 'video', 'film', 'audiobook', 'newsletter', 'blog', 'publisher', 'course',
        'mixed', 'podcastL', 'musicL', 'videoL', 'filmL', 'audiobookL', 'newsletterL', 'blogL', 'publisherL', 'courseL'
    ))
);

INSERT INTO medium (value) VALUES
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

    -- the hash of the last parsed feed file.
    -- used for comparison to determine if full re-parsing is needed.
    last_parsed_file_hash varchar_md5,

    -- the run-time environment container id
    container_id VARCHAR(12),

    created_at server_time_with_default,
    updated_at server_time_with_default
);

CREATE INDEX idx_feed_feed_flag_status_id ON feed(feed_flag_status_id);

CREATE TRIGGER set_updated_at_feed
BEFORE UPDATE ON feed
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_field();

CREATE TABLE feed_log (
    id SERIAL PRIMARY KEY,
    feed_id INTEGER NOT NULL UNIQUE REFERENCES feed(id) ON DELETE CASCADE,
    last_http_status INTEGER,
    last_good_http_status_time server_time,
    last_finished_parse_time server_time,
    parse_errors INTEGER DEFAULT 0
);

CREATE INDEX idx_feed_log_feed_id ON feed_log(feed_id);

--** CHANNEL

-- <channel>
CREATE TABLE channel (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    slug varchar_slug,
    feed_id INTEGER NOT NULL UNIQUE REFERENCES feed(id) ON DELETE CASCADE,
    podcast_index_id INTEGER UNIQUE NOT NULL,
    podcast_guid UUID UNIQUE, -- <podcast:guid>
    title varchar_normal,
    sortable_title varchar_short, -- all lowercase, ignores articles at beginning of title
    medium_id INTEGER REFERENCES medium(id),

    -- channels that have a PI value tag require special handling to request value data
    -- from the Podcast Index API.
    has_podcast_index_value BOOLEAN DEFAULT FALSE,

    -- this column is used for optimization purposes to determine if all of the items
    -- for a channel need to have their value time split remote items parsed.
    has_value_time_splits BOOLEAN DEFAULT FALSE,

    -- hidden items are no longer available in the rss feed, but are still in the database.
    hidden BOOLEAN DEFAULT FALSE,
    -- markedForDeletion items are no longer available in the rss feed, and may be able to be deleted.
    marked_for_deletion BOOLEAN DEFAULT FALSE
);

CREATE UNIQUE INDEX channel_podcast_guid_unique ON channel(podcast_guid) WHERE podcast_guid IS NOT NULL;
CREATE UNIQUE INDEX channel_slug ON channel(slug) WHERE slug IS NOT NULL;
CREATE INDEX idx_channel_feed_id ON channel(feed_id);
CREATE INDEX idx_channel_medium_id ON channel(medium_id);

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
    channel_id INTEGER NOT NULL UNIQUE REFERENCES channel(id) ON DELETE CASCADE,
    author varchar_normal, -- <itunes:author> and <author>
    episode_count INTEGER, -- aggregated count for convenience
    explicit BOOLEAN, -- <itunes:explicit>
    itunes_type_id INTEGER REFERENCES channel_itunes_type(id),
    language varchar_short, -- <language>
    last_pub_date server_time_with_default, -- <pubDate>
    website_link_url varchar_url -- <link>
);

CREATE INDEX idx_channel_about_channel_id ON channel_about(channel_id);
CREATE INDEX idx_channel_about_itunes_type_id ON channel_about(itunes_type_id);

--** CHANNEL > CATEGORY

-- <channel> -> <category>
CREATE TABLE channel_category (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES category(id) ON DELETE CASCADE
);

CREATE INDEX idx_channel_category_channel_id ON channel_category(channel_id);
CREATE INDEX idx_channel_category_category_id ON channel_category(category_id);

--** CHANNEL > CHAT

-- <channel> -> <podcast:chat>
CREATE TABLE channel_chat (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL UNIQUE REFERENCES channel(id) ON DELETE CASCADE,
    server varchar_fqdn NOT NULL,
    protocol varchar_short NOT NULL,
    account_id varchar_normal,
    space varchar_normal
);

CREATE INDEX idx_channel_chat_channel_id ON channel_chat(channel_id);

--** CHANNEL > DESCRIPTION

-- <channel> -> <description> AND possibly other tags that contain a description
CREATE TABLE channel_description (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL UNIQUE REFERENCES channel(id) ON DELETE CASCADE,
    value varchar_long NOT NULL
);

CREATE INDEX idx_channel_description_channel_id ON channel_description(channel_id);

--** CHANNEL > FUNDING

-- <channel> -> <podcast:funding>
CREATE TABLE channel_funding (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    title varchar_normal
);

CREATE INDEX idx_channel_funding_channel_id ON channel_funding(channel_id);

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

CREATE INDEX idx_channel_image_channel_id ON channel_image(channel_id);

--** CHANNEL > INTERNAL SETTINGS

CREATE TABLE channel_internal_settings (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    -- needed to approve which web domains can override the player with query params.
    -- this prevents malicious parties from misrepresenting the podcast contents on another website.
    embed_approved_media_url_paths TEXT
);

CREATE INDEX idx_channel_internal_settings_channel_id ON channel_internal_settings(channel_id);

--** CHANNEL > LICENSE

-- <channel> -> <podcast:license>
CREATE TABLE channel_license (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL UNIQUE REFERENCES channel(id) ON DELETE CASCADE,
    identifier varchar_normal NOT NULL,
    url varchar_url
);

CREATE INDEX idx_channel_license_channel_id ON channel_license(channel_id);

--** CHANNEL > LOCATION

-- <channel> -> <podcast:location>
CREATE TABLE channel_location (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL UNIQUE REFERENCES channel(id) ON DELETE CASCADE,
    geo varchar_normal,
    osm varchar_normal,
    CHECK (geo IS NOT NULL OR osm IS NOT NULL),
    name varchar_normal
);

CREATE INDEX idx_channel_location_channel_id ON channel_location(channel_id);

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

CREATE INDEX idx_channel_person_channel_id ON channel_person(channel_id);

--** CHANNEL > PODROLL

-- <channel> -> <podcast:podroll>
CREATE TABLE channel_podroll (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL UNIQUE REFERENCES channel(id) ON DELETE CASCADE
);

CREATE INDEX idx_channel_podroll_channel_id ON channel_podroll(channel_id);

--** CHANNEL > PODROLL > REMOTE ITEM

-- <channel> -> <podcast:podroll> --> <podcast:remoteItem>
CREATE TABLE channel_podroll_remote_item (
    id SERIAL PRIMARY KEY,
    channel_podroll_id INTEGER NOT NULL REFERENCES channel_podroll(id) ON DELETE CASCADE,
    feed_guid UUID NOT NULL,
    feed_url varchar_url,
    item_guid varchar_uri,
    title varchar_normal,
    medium_id INTEGER REFERENCES medium(id)
);

CREATE INDEX idx_channel_podroll_remote_item_channel_podroll_id ON channel_podroll_remote_item(channel_podroll_id);
CREATE INDEX idx_channel_podroll_remote_item_medium_id ON channel_podroll_remote_item(medium_id);
CREATE INDEX idx_channel_podroll_remote_item_feed_guid ON channel_podroll_remote_item(feed_guid);
CREATE INDEX idx_channel_podroll_remote_item_feed_url ON channel_podroll_remote_item(feed_url);
CREATE INDEX idx_channel_podroll_remote_item_item_guid ON channel_podroll_remote_item(item_guid);

--** CHANNEL > PUBLISHER

-- <channel> -> <podcast:publisher>
CREATE TABLE channel_publisher (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL UNIQUE REFERENCES channel(id) ON DELETE CASCADE
);

CREATE INDEX idx_channel_publisher_channel_id ON channel_publisher(channel_id);

--** CHANNEL > PUBLISHER > REMOTE ITEM

-- <channel> -> <podcast:publisher> -> <podcast:remoteItem>
CREATE TABLE channel_publisher_remote_item (
    id SERIAL PRIMARY KEY,
    channel_publisher_id INTEGER NOT NULL UNIQUE REFERENCES channel_publisher(id) ON DELETE CASCADE,
    feed_guid UUID NOT NULL,
    feed_url varchar_url,
    item_guid varchar_uri,
    title varchar_normal,
    medium_id INTEGER REFERENCES medium(id)
);

CREATE INDEX idx_channel_publisher_remote_item_channel_publisher_id ON channel_publisher_remote_item(channel_publisher_id);
CREATE INDEX idx_channel_publisher_remote_item_medium_id ON channel_publisher_remote_item(medium_id);
CREATE INDEX idx_channel_publisher_remote_item_feed_guid ON channel_publisher_remote_item(feed_guid);
CREATE INDEX idx_channel_publisher_remote_item_feed_url ON channel_publisher_remote_item(feed_url);
CREATE INDEX idx_channel_publisher_remote_item_item_guid ON channel_publisher_remote_item(item_guid);

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
    medium_id INTEGER REFERENCES medium(id)
);

CREATE INDEX idx_channel_remote_item_channel_id ON channel_remote_item(channel_id);
CREATE INDEX idx_channel_remote_item_medium_id ON channel_remote_item(medium_id);
CREATE INDEX idx_channel_remote_item_feed_guid ON channel_remote_item(feed_guid);
CREATE INDEX idx_channel_remote_item_feed_url ON channel_remote_item(feed_url);
CREATE INDEX idx_channel_remote_item_item_guid ON channel_remote_item(item_guid);

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

CREATE INDEX idx_channel_season_channel_id ON channel_season(channel_id);

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

CREATE INDEX idx_channel_social_interact_channel_id ON channel_social_interact(channel_id);

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
    channel_season_id INTEGER REFERENCES channel_season(id),
    UNIQUE (channel_id, url)
);

CREATE INDEX idx_channel_trailer_channel_id ON channel_trailer(channel_id);
CREATE INDEX idx_channel_trailer_channel_season_id ON channel_trailer(channel_season_id);

--** CHANNEL > TXT

-- <channel> -> <podcast:txt>
CREATE TABLE channel_txt (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    purpose varchar_normal,
    value varchar_long NOT NULL
);

CREATE INDEX idx_channel_txt_channel_id ON channel_txt(channel_id);

--** CHANNEL > VALUE

-- <channel> -> <podcast:value>
CREATE TABLE channel_value (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    method varchar_short NOT NULL,
    suggested FLOAT
);

CREATE INDEX idx_channel_value_channel_id ON channel_value(channel_id);

--** CHANNEL > VALUE > RECEIPIENT

-- <channel> -> <podcast:value> -> <podcast:valueRecipient>
CREATE TABLE channel_value_recipient (
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

CREATE INDEX idx_channel_value_recipient_channel_value_id ON channel_value_recipient(channel_value_id);

--** ITEM

-- Technically the item table could be named channel_item, but it seems easier to understand as item.

-- <channel> -> <item>
CREATE TABLE item (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    slug varchar_slug,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    guid varchar_uri, -- <guid>
    guid_enclosure_url varchar_url, -- enclosure url
    pubdate TIMESTAMPTZ, -- <pubDate>
    title varchar_normal, -- <title>

    -- hidden items are no longer available in the rss feed, but are still in the database.
    hidden BOOLEAN DEFAULT FALSE,
    -- markedForDeletion items are no longer available in the rss feed, and may be able to be deleted.
    marked_for_deletion BOOLEAN DEFAULT FALSE,

    -- Ensure either guid or guid_enclosure_url is required
    CHECK (guid IS NOT NULL OR guid_enclosure_url IS NOT NULL)
);

CREATE UNIQUE INDEX item_slug ON item(slug) WHERE slug IS NOT NULL;
CREATE INDEX idx_item_channel_id ON item(channel_id);

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
    item_id INTEGER NOT NULL UNIQUE REFERENCES item(id) ON DELETE CASCADE,
    duration media_player_time, -- <itunes:duration>
    explicit BOOLEAN, -- <itunes:explicit>
    website_link_url varchar_url, -- <link>
    item_itunes_episode_type_id INTEGER REFERENCES item_itunes_episode_type(id) -- <itunes:episodeType>
);

CREATE INDEX idx_item_about_item_id ON item_about(item_id);
CREATE INDEX idx_item_about_item_itunes_episode_type_id ON item_about(item_itunes_episode_type_id);

--** ITEM > CHAPTERS

-- <item> -> <podcast:chapters>
CREATE TABLE item_chapters_feed (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL UNIQUE REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    type varchar_short NOT NULL
);

CREATE INDEX idx_item_chapters_feed_item_id ON item_chapters_feed(item_id);

--** ITEM > CHAPTERS > LOG

-- <item> -> <podcast:chapters> -> parsing logs

CREATE TABLE item_chapters_feed_log (
    id SERIAL PRIMARY KEY,
    item_chapters_feed_id INTEGER NOT NULL UNIQUE REFERENCES item_chapters_feed(id) ON DELETE CASCADE,
    last_http_status INTEGER,
    last_good_http_status_time server_time,
    last_finished_parse_time server_time,
    parse_errors INTEGER DEFAULT 0
);

CREATE INDEX idx_item_chapters_feed_log_item_chapters_feed_id ON item_chapters_feed_log(item_chapters_feed_id);

--** ITEM > CHAPTERS > CHAPTER

-- -- <item> -> <podcast:chapters> -> chapter items correspond with jsonChapters.md example file
CREATE TABLE item_chapter (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    item_chapters_feed_id INTEGER NOT NULL REFERENCES item_chapters_feed(id) ON DELETE CASCADE,
    start_time media_player_time NOT NULL,
    end_time media_player_time,
    title varchar_normal,
    img varchar_url,
    web_url varchar_url,
    table_of_contents BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_item_chapter_item_chapters_feed_id ON item_chapter(item_chapters_feed_id);

--** ITEM > CHAPTER > LOCATION

-- <item> -> <podcast:chapters> -> chapter items correspond with jsonChapters.md example file
CREATE TABLE item_chapter_location (
    id SERIAL PRIMARY KEY,
    item_chapter_id INTEGER NOT NULL UNIQUE REFERENCES item_chapter(id) ON DELETE CASCADE,
    geo varchar_normal,
    osm varchar_normal,
    CHECK (geo IS NOT NULL OR osm IS NOT NULL),
    name varchar_normal
);

CREATE INDEX idx_item_chapter_location_item_chapter_id ON item_chapter_location(item_chapter_id);

--** ITEM > CHAT

-- <item> -> <podcast:chat>
CREATE TABLE item_chat (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL UNIQUE REFERENCES item(id) ON DELETE CASCADE,
    server varchar_fqdn NOT NULL,
    protocol varchar_short NOT NULL,
    account_id varchar_normal,
    space varchar_normal
);

CREATE INDEX idx_item_chat_item_id ON item_chat(item_id);

--** ITEM > CONTENT LINK

-- <item> -> <podcast:contentLink>
CREATE TABLE item_content_link (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    href varchar_url NOT NULL,
    title varchar_normal
);

CREATE INDEX idx_item_content_link_item_id ON item_content_link(item_id);

--** ITEM > DESCRIPTION

-- <item> -> <description> AND possibly other tags that contain a description
CREATE TABLE item_description (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL UNIQUE REFERENCES item(id) ON DELETE CASCADE,
    value varchar_long NOT NULL
);

CREATE INDEX idx_item_description_item_id ON item_description(item_id);

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

CREATE INDEX idx_item_enclosure_item_id ON item_enclosure(item_id);

-- <item> -> <podcast:alternateEnclosure> -> <podcast:source>
CREATE TABLE item_enclosure_source (
    id SERIAL PRIMARY KEY,
    item_enclosure_id INTEGER NOT NULL REFERENCES item_enclosure(id) ON DELETE CASCADE,
    uri varchar_uri NOT NULL,
    content_type varchar_short
);

CREATE INDEX idx_item_enclosure_source_item_id ON item_enclosure_source(item_enclosure_id);

-- <item> -> <podcast:alternateEnclosure> -> <podcast:integrity>
CREATE TABLE item_enclosure_integrity (
    id SERIAL PRIMARY KEY,
    item_enclosure_id INTEGER NOT NULL UNIQUE REFERENCES item_enclosure_source(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('sri', 'pgp-signature')),
    value varchar_long NOT NULL
);

CREATE INDEX idx_item_enclosure_integrity_item_enclosure_id ON item_enclosure_integrity(item_enclosure_id);

--** ITEM > FUNDING

-- <item> -> <podcast:funding>
CREATE TABLE item_funding (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    url varchar_url NOT NULL,
    title varchar_normal
);

CREATE INDEX idx_item_funding_item_id ON item_funding(item_id);

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

CREATE INDEX idx_item_image_item_id ON item_image(item_id);

--** ITEM > LICENSE

-- <item> -> <podcast:license>
CREATE TABLE item_license (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL UNIQUE REFERENCES item(id) ON DELETE CASCADE,
    identifier varchar_normal NOT NULL,
    url varchar_url
);

CREATE INDEX idx_item_license_item_id ON item_license(item_id);

--** ITEM > LOCATION

-- <item> -> <podcast:location>
CREATE TABLE item_location (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL UNIQUE REFERENCES item(id) ON DELETE CASCADE,
    geo varchar_normal,
    osm varchar_normal,
    CHECK (geo IS NOT NULL OR osm IS NOT NULL),
    name varchar_normal
);

CREATE INDEX idx_item_location_item_id ON item_location(item_id);

--** ITEM > PERSON

-- <item> -> <podcast:person>
CREATE TABLE item_person (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    name varchar_normal NOT NULL,
    role varchar_normal,
    person_group varchar_normal DEFAULT 'cast', -- group is a reserved keyword in sql
    img varchar_url,
    href varchar_url
);

CREATE INDEX idx_item_person_item_id ON item_person(item_id);

--** ITEM > SEASON

-- <item> -> <podcast:season>
CREATE TABLE item_season (
    id SERIAL PRIMARY KEY,
    channel_season_id INTEGER NOT NULL REFERENCES channel_season(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    title varchar_normal
);

CREATE INDEX idx_item_season_channel_season_id ON item_season(channel_season_id);
CREATE INDEX idx_item_season_item_id ON item_season(item_id);

--** ITEM > SEASON > EPISODE

-- <item> -> <podcast:season> -> <podcast:episode>
CREATE TABLE item_season_episode (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL UNIQUE REFERENCES item(id) ON DELETE CASCADE,
    display varchar_short,
    number FLOAT NOT NULL
);

CREATE INDEX idx_item_season_episode_item_id ON item_season_episode(item_id);

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

CREATE INDEX idx_item_social_interact_item_id ON item_social_interact(item_id);

--** ITEM > SOUNDBITE

-- <item> -> <podcast:soundbite>
CREATE TABLE item_soundbite (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    start_time media_player_time NOT NULL,
    duration media_player_time NOT NULL,
    title varchar_normal
);

CREATE INDEX idx_item_soundbite_item_id ON item_soundbite(item_id);

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

CREATE INDEX idx_item_transcript_item_id ON item_transcript(item_id);

--** ITEM > TXT

-- <item> -> <podcast:txt>
CREATE TABLE item_txt (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    purpose varchar_normal,
    value varchar_long NOT NULL
);

CREATE INDEX idx_item_txt_item_id ON item_txt(item_id);

--** ITEM > VALUE

-- <item> -> <podcast:value>
CREATE TABLE item_value (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    type varchar_short NOT NULL,
    method varchar_short NOT NULL,
    suggested FLOAT
);

CREATE INDEX idx_item_value_item_id ON item_value(item_id);

--** ITEM > VALUE > RECEIPIENT

-- <item> -> <podcast:value> -> <podcast:valueRecipient>
CREATE TABLE item_value_recipient (
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

CREATE INDEX idx_item_value_recipient_item_value_id ON item_value_recipient(item_value_id);

--** ITEM > VALUE > TIME SPLIT

-- <item> -> <podcast:value> -> <podcast:valueTimeSplit>
CREATE TABLE item_value_time_split (
    id SERIAL PRIMARY KEY,
    item_value_id INTEGER NOT NULL REFERENCES item_value(id) ON DELETE CASCADE,
    start_time media_player_time NOT NULL,
    duration media_player_time NOT NULL,
    remote_start_time media_player_time DEFAULT 0,
    remote_percentage media_player_time DEFAULT 100
);

CREATE INDEX idx_item_value_time_split_item_value_id ON item_value_time_split(item_value_id);

--** ITEM > VALUE > TIME SPLIT > REMOTE ITEM

-- <item> -> <podcast:value> -> <podcast:valueTimeSplit> -> <podcast:remoteItem>
CREATE TABLE item_value_time_split_remote_item (
    id SERIAL PRIMARY KEY,
    item_value_time_split_id INTEGER NOT NULL UNIQUE REFERENCES item_value_time_split(id) ON DELETE CASCADE,
    feed_guid UUID NOT NULL,
    feed_url varchar_url,
    item_guid varchar_uri,
    title varchar_normal
);

CREATE INDEX idx_item_value_time_split_remote_item_item_value_time_split_id ON item_value_time_split_remote_item(item_value_time_split_id);
CREATE INDEX idx_item_value_time_split_remote_item_feed_guid ON item_value_time_split_remote_item(feed_guid);
CREATE INDEX idx_item_value_time_split_remote_item_feed_url ON item_value_time_split_remote_item(feed_url);
CREATE INDEX idx_item_value_time_split_remote_item_item_guid ON item_value_time_split_remote_item(item_guid);

--** ITEM > VALUE > TIME SPLIT > VALUE RECIPEINT

-- <item> -> <podcast:value> -> <podcast:valueTimeSplit> -> <podcast:valueRecipient>
CREATE TABLE item_value_time_split_recipient (
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

CREATE INDEX idx_item_value_time_split_recipient_item_value_time_split_id ON item_value_time_split_recipient(item_value_time_split_id);

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
    item_id INTEGER NOT NULL UNIQUE REFERENCES item(id) ON DELETE CASCADE,
    live_item_status_id INTEGER NOT NULL REFERENCES live_item_status(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    chat_web_url varchar_url
);

CREATE INDEX idx_live_item_item_id ON live_item(item_id);
CREATE INDEX idx_live_item_live_item_status_id ON live_item(live_item_status_id);

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

CREATE INDEX idx_account_sharable_status_id ON account(sharable_status_id);

CREATE TABLE account_credentials (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE UNIQUE,
    email varchar_email UNIQUE NOT NULL,
    password varchar_password NOT NULL
);

CREATE INDEX idx_account_credentials_account_id ON account_credentials(account_id);

CREATE TABLE account_profile (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE UNIQUE,
    display_name varchar_normal,
    bio varchar_long
);

CREATE INDEX idx_account_profile_account_id ON account_profile(account_id);

CREATE TABLE account_reset_password (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE UNIQUE,
    reset_token varchar_guid,
    reset_token_expires_at TIMESTAMP
);

CREATE INDEX idx_account_reset_password_account_id ON account_reset_password(account_id);

CREATE TABLE account_verification (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE UNIQUE,
    verification_token varchar_guid,
    verification_token_expires_at TIMESTAMP
);

CREATE INDEX idx_account_verification_account_id ON account_verification(account_id);

CREATE TABLE account_membership (
    id SERIAL PRIMARY KEY,
    tier TEXT UNIQUE CHECK (tier IN ('trial', 'basic'))
);

INSERT INTO account_membership (tier) VALUES ('trial'), ('basic');

CREATE TABLE account_membership_status (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE UNIQUE,
    account_membership_id INTEGER NOT NULL REFERENCES account_membership(id),
    membership_expires_at TIMESTAMP
);

CREATE INDEX idx_account_membership_status_account_id ON account_membership_status(account_id);
CREATE INDEX idx_account_membership_status_account_membership_id ON account_membership_status(account_membership_id);

CREATE TABLE account_admin_roles (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE UNIQUE,
    dev_admin BOOLEAN DEFAULT FALSE,
    podping_admin BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_account_admin_roles_account_id ON account_admin_roles(account_id);

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

CREATE INDEX idx_clip_account_id ON clip(account_id);
CREATE INDEX idx_clip_item_id ON clip(item_id);
CREATE INDEX idx_clip_sharable_status_id ON clip(sharable_status_id);

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
    medium_id INTEGER NOT NULL REFERENCES medium(id)
);

CREATE INDEX idx_playlist_account_id ON playlist(account_id);
CREATE INDEX idx_playlist_sharable_status_id ON playlist(sharable_status_id);
CREATE INDEX idx_playlist_medium_id ON playlist(medium_id);

CREATE TABLE playlist_resource_base (
    id SERIAL PRIMARY KEY,
    playlist_id INTEGER NOT NULL REFERENCES playlist(id) ON DELETE CASCADE,
    list_position list_position NOT NULL CHECK (list_position != 0 OR list_position = 0::numeric),
    UNIQUE (playlist_id, list_position)
);

CREATE INDEX idx_playlist_resource_base_playlist_id ON playlist_resource_base(playlist_id);

CREATE TABLE playlist_resource_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE INDEX idx_playlist_resource_item_item_id ON playlist_resource_item(item_id);

CREATE TABLE playlist_resource_item_add_by_rss (
    resource_data jsonb NOT NULL
) INHERITS (playlist_resource_base);

CREATE INDEX idx_playlist_resource_item_add_by_rss_resource_data ON playlist_resource_item_add_by_rss USING gin (resource_data);

CREATE TABLE playlist_resource_item_chapter (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE INDEX idx_playlist_resource_item_chapter_item_chapter_id ON playlist_resource_item_chapter(item_chapter_id);

CREATE TABLE playlist_resource_clip (
    clip_id INTEGER NOT NULL REFERENCES clip(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE INDEX idx_playlist_resource_clip_clip_id ON playlist_resource_clip(clip_id);

CREATE TABLE playlist_resource_item_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE INDEX idx_playlist_resource_item_soundbite_soundbite_id ON playlist_resource_item_soundbite(soundbite_id);

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
    medium_id INTEGER NOT NULL REFERENCES medium(id),
    UNIQUE (account_id, medium_id)
);

CREATE INDEX idx_queue_account_id ON queue(account_id);
CREATE INDEX idx_queue_medium_id ON queue(medium_id);

CREATE TABLE queue_resource_base (
    id SERIAL PRIMARY KEY,
    queue_id INTEGER NOT NULL REFERENCES queue(id) ON DELETE CASCADE,
    UNIQUE (queue_id, list_position),
    list_position list_position NOT NULL CHECK (list_position != 0 OR list_position = 0::numeric),
    playback_position media_player_time NOT NULL DEFAULT 0,
    media_file_duration media_player_time NOT NULL DEFAULT 0,
    completed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_queue_resource_base_queue_id ON queue_resource_base(queue_id);

CREATE TABLE queue_resource_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_item_item_id ON queue_resource_item(item_id);

CREATE TABLE queue_resource_item_add_by_rss (
    resource_data jsonb NOT NULL,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_item_add_by_rss_resource_data ON queue_resource_item_add_by_rss USING gin (resource_data);

CREATE TABLE queue_resource_item_chapter (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_item_chapter_item_chapter_id ON queue_resource_item_chapter(item_chapter_id);

CREATE TABLE queue_resource_clip (
    clip_id INTEGER NOT NULL REFERENCES clip(id) ON DELETE CASCADE,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_clip_clip_id ON queue_resource_clip(clip_id);

CREATE TABLE queue_resource_item_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE,
    UNIQUE (queue_id)
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_item_soundbite_soundbite_id ON queue_resource_item_soundbite(soundbite_id);

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

CREATE INDEX idx_account_following_account_account_id ON account_following_account(account_id);
CREATE INDEX idx_account_following_account_following_account_id ON account_following_account(following_account_id);

CREATE TABLE account_following_channel (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, channel_id)
);

CREATE INDEX idx_account_following_channel_account_id ON account_following_channel(account_id);
CREATE INDEX idx_account_following_channel_channel_id ON account_following_channel(channel_id);

CREATE TABLE account_following_playlist (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    playlist_id INTEGER NOT NULL REFERENCES playlist(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, playlist_id)
);

CREATE INDEX idx_account_following_playlist_account_id ON account_following_playlist(account_id);
CREATE INDEX idx_account_following_playlist_playlist_id ON account_following_playlist(playlist_id);

CREATE TABLE account_following_add_by_rss_channel (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    feed_url varchar_url NOT NULL,
    PRIMARY KEY (account_id, feed_url),
    title varchar_normal,
    image_url varchar_url
);

CREATE INDEX idx_account_following_add_by_rss_channel_account_id ON account_following_add_by_rss_channel(account_id);

-- 0007

CREATE TABLE account_notification (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    PRIMARY KEY (channel_id, account_id)
);

CREATE INDEX idx_account_notification_channel_id ON account_notification(channel_id);
CREATE INDEX idx_account_notification_account_id ON account_notification(account_id);

CREATE TABLE account_up_device (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    up_endpoint varchar_url PRIMARY KEY,
    up_public_key varchar_long NOT NULL,
    up_auth_key varchar_long NOT NULL
);

CREATE INDEX idx_account_up_device_account_id ON account_up_device(account_id);

CREATE TABLE account_fcm_device (
    fcm_token varchar_fcm_token PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE
);

CREATE INDEX idx_account_fcm_device_account_id ON account_fcm_device(account_id);

-- 0008

CREATE TABLE account_paypal_order (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    payment_id VARCHAR PRIMARY KEY,
    state VARCHAR
);

CREATE INDEX idx_account_paypal_order_account_id ON account_paypal_order(account_id);

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

CREATE INDEX idx_account_app_store_purchase_account_id ON account_app_store_purchase(account_id);

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

CREATE INDEX idx_account_google_play_purchase_account_id ON account_google_play_purchase(account_id);

-- 0009

CREATE TABLE membership_claim_token (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claimed BOOLEAN DEFAULT FALSE,
    months_to_add INT DEFAULT 1,
    account_membership_id INT REFERENCES account_membership(id) ON DELETE CASCADE
);

CREATE INDEX idx_membership_claim_token_account_membership_id ON membership_claim_token(account_membership_id);


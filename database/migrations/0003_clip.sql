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

CREATE TABLE clip_archived (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    channel_podcast_index_id INTEGER NOT NULL,
    channel_title varchar_normal,
    channel_images jsonb,
    item_guid varchar_uri,
    item_guid_enclosure_url varchar_url,
    item_alternate_enclosures jsonb NOT NULL,
    item_title varchar_normal,
    item_pub_date TIMESTAMPTZ,
    start_time media_player_time NOT NULL,
    end_time media_player_time,
    title varchar_normal,
    description varchar_long,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id)
);

CREATE INDEX idx_clip_archived_account_id ON clip_archived(account_id);
CREATE INDEX idx_clip_archived_channel_podcast_index_id ON clip_archived(channel_podcast_index_id);
CREATE INDEX idx_clip_archived_sharable_status_id ON clip_archived(sharable_status_id);
CREATE INDEX idx_clip_archived_item_guid ON clip_archived(item_guid);
CREATE INDEX idx_clip_archived_item_guid_enclosure_url ON clip_archived(item_guid_enclosure_url);

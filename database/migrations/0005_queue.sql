-- 0005 migration

CREATE TABLE queue (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    medium_id INTEGER NOT NULL REFERENCES medium(id),
    UNIQUE (account_id, medium_id)
);

CREATE INDEX idx_queue_account_id ON queue(account_id);
CREATE INDEX idx_queue_medium_id ON queue(medium_id);

CREATE TABLE queue_resource (
    id SERIAL PRIMARY KEY,
    queue_id INTEGER NOT NULL REFERENCES queue(id) ON DELETE CASCADE,
    list_position list_position NOT NULL CHECK (list_position != 0 OR list_position = 0::numeric),
    playback_position media_player_time NOT NULL DEFAULT 0,
    media_file_duration media_player_time NOT NULL DEFAULT 0,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    add_by_rss_resource_data jsonb,
    add_by_rss_hash_id varchar_md5,
    item_chapter_id INTEGER REFERENCES item_chapter(id) ON DELETE CASCADE,
    clip_id INTEGER REFERENCES clip(id) ON DELETE CASCADE,
    item_soundbite_id INTEGER REFERENCES item_soundbite(id) ON DELETE CASCADE,
    UNIQUE (queue_id, list_position),
    CHECK (
        (item_id IS NOT NULL)::int +
        (add_by_rss_hash_id IS NOT NULL)::int +
        (item_chapter_id IS NOT NULL)::int +
        (clip_id IS NOT NULL)::int +
        (item_soundbite_id IS NOT NULL)::int = 1
    ),
    UNIQUE (queue_id, item_id),
    UNIQUE (queue_id, add_by_rss_hash_id),
    UNIQUE (queue_id, item_chapter_id),
    UNIQUE (queue_id, clip_id),
    UNIQUE (queue_id, item_soundbite_id)
);

CREATE INDEX idx_queue_resource_queue_id ON queue_resource(queue_id);
CREATE INDEX idx_queue_resource_item_id ON queue_resource(item_id);
CREATE INDEX idx_queue_resource_add_by_rss_hash_id ON queue_resource(add_by_rss_hash_id);
CREATE INDEX idx_queue_resource_item_chapter_id ON queue_resource(item_chapter_id);
CREATE INDEX idx_queue_resource_clip_id ON queue_resource(clip_id);
CREATE INDEX idx_queue_resource_soundbite_id ON queue_resource(item_soundbite_id);
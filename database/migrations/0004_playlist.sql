-- 0004 migration

CREATE TABLE playlist (
    id SERIAL PRIMARY KEY,
    id_text nano_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id),
    title varchar_normal,
    description varchar_long,
    is_default_favorites BOOLEAN DEFAULT FALSE,
    item_count INTEGER DEFAULT 0,
    medium_id INTEGER NOT NULL REFERENCES medium(id),
    last_updated server_time_with_default NOT NULL
);

CREATE UNIQUE INDEX idx_playlist_account_medium_default_favorites
    ON playlist (account_id, medium_id)
    WHERE is_default_favorites = TRUE;

CREATE INDEX idx_playlist_account_id ON playlist(account_id);
CREATE INDEX idx_playlist_sharable_status_id ON playlist(sharable_status_id);
CREATE INDEX idx_playlist_medium_id ON playlist(medium_id);
CREATE INDEX idx_playlist_last_updated ON playlist(last_updated);

CREATE TABLE playlist_resource (
    id SERIAL PRIMARY KEY,
    playlist_id INTEGER NOT NULL REFERENCES playlist(id) ON DELETE CASCADE,
    list_position list_position NOT NULL,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    clip_id INTEGER REFERENCES clip(id) ON DELETE CASCADE,
    item_soundbite_id INTEGER REFERENCES item_soundbite(id) ON DELETE CASCADE,
    add_by_rss_resource_data jsonb,
    add_by_rss_hash_id varchar_md5,
    UNIQUE (playlist_id, list_position),
    CHECK (
        (item_id IS NOT NULL)::int +
        (add_by_rss_hash_id IS NOT NULL)::int +
        (clip_id IS NOT NULL)::int +
        (item_soundbite_id IS NOT NULL)::int = 1
    ),
    UNIQUE (playlist_id, item_id),
    UNIQUE (playlist_id, clip_id),
    UNIQUE (playlist_id, item_soundbite_id),
    UNIQUE (playlist_id, add_by_rss_hash_id)
);

CREATE INDEX idx_playlist_resource_playlist_id ON playlist_resource(playlist_id);
CREATE INDEX idx_playlist_resource_item_id ON playlist_resource(item_id);
CREATE INDEX idx_playlist_resource_clip_id ON playlist_resource(clip_id);
CREATE INDEX idx_playlist_resource_soundbite_id ON playlist_resource(item_soundbite_id);
CREATE INDEX idx_playlist_resource_hash_id ON playlist_resource(add_by_rss_hash_id);

-- Example: Limit playlist to 10000 resources
CREATE OR REPLACE FUNCTION enforce_playlist_resource_limit()
RETURNS TRIGGER AS $$
DECLARE
    resource_count INTEGER;
    max_resources CONSTANT INTEGER := 10000;
BEGIN
    SELECT COUNT(*) INTO resource_count
    FROM playlist_resource
    WHERE playlist_id = NEW.playlist_id;

    IF resource_count >= max_resources THEN
        RAISE EXCEPTION 'Playlist % cannot have more than % resources', NEW.playlist_id, max_resources;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER playlist_resource_limit_trigger
BEFORE INSERT ON playlist_resource
FOR EACH ROW
EXECUTE FUNCTION enforce_playlist_resource_limit();

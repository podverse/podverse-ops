-- 0004 migration

CREATE TABLE playlist (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id),
    title varchar_normal,
    description varchar_long,
    is_default_favorites BOOLEAN DEFAULT FALSE,
    item_count INTEGER DEFAULT 0,
    medium_id INTEGER NOT NULL REFERENCES medium(id),
    UNIQUE (account_id, medium_id, is_default_favorites) WHERE is_default_favorites = TRUE
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
    -- Delete child rows in the correct order to avoid recursion
    DELETE FROM playlist_resource_item WHERE id = OLD.id;
    DELETE FROM playlist_resource_item_add_by_rss WHERE id = OLD.id;
    DELETE FROM playlist_resource_item_chapter WHERE id = OLD.id;
    DELETE FROM playlist_resource_clip WHERE id = OLD.id;
    DELETE FROM playlist_resource_item_soundbite WHERE id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Add a new trigger on the playlist_resource_base table
CREATE TRIGGER delete_playlist_resource_base_trigger
BEFORE DELETE ON playlist_resource_base
FOR EACH ROW
EXECUTE FUNCTION delete_playlist_resource_base();

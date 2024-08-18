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

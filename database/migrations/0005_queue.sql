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
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_item_item_id ON queue_resource_item(item_id);

CREATE TABLE queue_resource_item_add_by_rss (
    resource_data jsonb NOT NULL
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_item_add_by_rss_resource_data ON queue_resource_item_add_by_rss USING gin (resource_data);

CREATE TABLE queue_resource_item_chapter (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_item_chapter_item_chapter_id ON queue_resource_item_chapter(item_chapter_id);

CREATE TABLE queue_resource_clip (
    clip_id INTEGER NOT NULL REFERENCES clip(id) ON DELETE CASCADE
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_clip_clip_id ON queue_resource_clip(clip_id);

CREATE TABLE queue_resource_item_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE
) INHERITS (queue_resource_base);

CREATE INDEX idx_queue_resource_item_soundbite_soundbite_id ON queue_resource_item_soundbite(soundbite_id);

CREATE OR REPLACE FUNCTION delete_queue_resource_base()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete child rows in the correct order to avoid recursion
    DELETE FROM queue_resource_item WHERE id = OLD.id;
    DELETE FROM queue_resource_item_add_by_rss WHERE id = OLD.id;
    DELETE FROM queue_resource_item_chapter WHERE id = OLD.id;
    DELETE FROM queue_resource_clip WHERE id = OLD.id;
    DELETE FROM queue_resource_item_soundbite WHERE id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Add a new trigger on the queue_resource_base table
CREATE TRIGGER delete_queue_resource_base_trigger
BEFORE DELETE ON queue_resource_base
FOR EACH ROW
EXECUTE FUNCTION delete_queue_resource_base();
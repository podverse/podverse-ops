-- 0005 migration

CREATE TABLE queue (
    id SERIAL PRIMARY KEY,
    id_text nano_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    medium_id INTEGER NOT NULL REFERENCES medium(id),
    UNIQUE (account_id, medium_id),
    is_active_queue BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_queue_account_id ON queue(account_id);
CREATE INDEX idx_queue_medium_id ON queue(medium_id);

CREATE TABLE queue_resource (
    id SERIAL PRIMARY KEY,
    queue_id INTEGER NOT NULL REFERENCES queue(id) ON DELETE CASCADE,
    list_position list_position NOT NULL,
    playback_position media_player_time NOT NULL DEFAULT 0,
    media_file_duration media_player_time NOT NULL DEFAULT 0,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    item_id INTEGER REFERENCES item(id) ON DELETE CASCADE,
    clip_id INTEGER REFERENCES clip(id) ON DELETE CASCADE,
    item_soundbite_id INTEGER REFERENCES item_soundbite(id) ON DELETE CASCADE,
    add_by_rss_resource_data jsonb,
    add_by_rss_hash_id varchar_md5,
    UNIQUE (queue_id, list_position),
    CHECK (
        (item_id IS NOT NULL)::int +
        (add_by_rss_hash_id IS NOT NULL)::int +
        (clip_id IS NOT NULL)::int +
        (item_soundbite_id IS NOT NULL)::int = 1
    ),
    UNIQUE (queue_id, item_id),
    UNIQUE (queue_id, clip_id),
    UNIQUE (queue_id, item_soundbite_id),
    UNIQUE (queue_id, add_by_rss_hash_id)
);

CREATE INDEX idx_queue_resource_queue_id ON queue_resource(queue_id);
CREATE INDEX idx_queue_resource_item_id ON queue_resource(item_id);
CREATE INDEX idx_queue_resource_clip_id ON queue_resource(clip_id);
CREATE INDEX idx_queue_resource_soundbite_id ON queue_resource(item_soundbite_id);
CREATE INDEX idx_queue_resource_add_by_rss_hash_id ON queue_resource(add_by_rss_hash_id);

-- Example: Limit queue to 10000 resources
CREATE OR REPLACE FUNCTION enforce_queue_resource_limit()
RETURNS TRIGGER AS $$
DECLARE
    resource_count INTEGER;
    max_resources CONSTANT INTEGER := 10000;
    min_id INTEGER;
BEGIN
    SELECT COUNT(*) INTO resource_count
    FROM queue_resource
    WHERE queue_id = NEW.queue_id;

    IF resource_count >= max_resources THEN
        -- Find the id of the resource with the lowest list_position
        SELECT id INTO min_id
        FROM queue_resource
        WHERE queue_id = NEW.queue_id
        ORDER BY list_position ASC
        LIMIT 1;

        IF min_id IS NOT NULL THEN
            DELETE FROM queue_resource WHERE id = min_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER queue_resource_limit_trigger
BEFORE INSERT ON queue_resource
FOR EACH ROW
EXECUTE FUNCTION enforce_queue_resource_limit();
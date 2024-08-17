CREATE TABLE queue_resource_base (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    list_position list_position NOT NULL CHECK (list_position != 0 OR list_position = 0::numeric),
    UNIQUE (account_id, list_position),
    playback_position media_player_time NOT NULL DEFAULT 0,
    media_file_duration FLOAT NOT NULL DEFAULT 0,
    completed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE queue_resource_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (queue_resource_base);

CREATE TABLE queue_resource_item_add_by_rss (
    item_data jsonb NOT NULL,
    UNIQUE (account_id)
) INHERITS (queue_resource_base);

CREATE TABLE queue_resource_item_chapter (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (queue_resource_base);

CREATE TABLE queue_resource_account_clip (
    account_clip_id INTEGER NOT NULL REFERENCES account_clip(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (queue_resource_base);

CREATE TABLE queue_resource_item_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (queue_resource_base);

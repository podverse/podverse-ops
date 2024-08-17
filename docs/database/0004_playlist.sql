CREATE TABLE playlist (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id),
    title varchar_normal,
    description varchar_long,
    is_default_favorites BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT FALSE,
    item_count INTEGER DEFAULT 0
);

CREATE TABLE playlist_medium (
    playlist_id INTEGER NOT NULL REFERENCES playlist(id) ON DELETE CASCADE,
    UNIQUE (playlist_id)
) INHERITS (medium_base);

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
    item_data jsonb NOT NULL
) INHERITS (playlist_resource_base);

CREATE TABLE playlist_resource_chapter (
    chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE TABLE playlist_resource_account_clip (
    account_clip_id INTEGER NOT NULL REFERENCES account_clip(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

CREATE TABLE playlist_resource_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE
) INHERITS (playlist_resource_base);

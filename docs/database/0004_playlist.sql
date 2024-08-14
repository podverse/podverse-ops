CREATE TABLE playlist (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL,
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

CREATE TABLE playlist_item_base (
    id SERIAL PRIMARY KEY,
    playlist_id INTEGER NOT NULL REFERENCES playlist(id) ON DELETE CASCADE,
    position numeric_20_11 NOT NULL,
    UNIQUE (playlist_id, position)
);

CREATE TABLE playlist_item_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE
) INHERITS (playlist_item_base);

CREATE TABLE playlist_item_chapter (
    chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE
) INHERITS (playlist_item_base);

CREATE TABLE playlist_item_clip (
    clip_id INTEGER NOT NULL REFERENCES item_clip(id) ON DELETE CASCADE
) INHERITS (playlist_item_base);

CREATE TABLE playlist_item_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE
) INHERITS (playlist_item_base);

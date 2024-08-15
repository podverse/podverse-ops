CREATE TABLE queue_content_base (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    position numeric_20_11 NOT NULL
);

CREATE TABLE queue_content_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (queue_content_base);

CREATE TABLE queue_content_item_add_by_rss (
    item_data jsonb NOT NULL,
    UNIQUE (account_id)
) INHERITS (queue_content_base);

CREATE TABLE queue_content_item_chapter (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (queue_content_base);

CREATE TABLE queue_clip (
    clip_id INTEGER NOT NULL REFERENCES clip(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (queue_content_base);

CREATE TABLE queue_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (queue_content_base);

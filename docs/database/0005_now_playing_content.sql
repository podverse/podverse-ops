CREATE TABLE now_playing_content_base (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    playback_position numeric_20_11 NOT NULL
);

CREATE TABLE now_playing_content_item (
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (now_playing_content_base);

CREATE TABLE now_playing_content_item_add_by_rss (
    item_data jsonb NOT NULL,
    UNIQUE (account_id)
) INHERITS (now_playing_content_base);

CREATE TABLE now_playing_content_item_chapter (
    item_chapter_id INTEGER NOT NULL REFERENCES item_chapter(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (now_playing_content_base);

CREATE TABLE now_playing_content_clip (
    clip_id INTEGER NOT NULL REFERENCES clip(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (now_playing_content_base);

CREATE TABLE now_playing_content_item_soundbite (
    soundbite_id INTEGER NOT NULL REFERENCES item_soundbite(id) ON DELETE CASCADE,
    UNIQUE (account_id)
) INHERITS (now_playing_content_base);

/* Ensure that an account can only have one of any type assigned to it at a time */

CREATE OR REPLACE FUNCTION check_account_id_uniqueness()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM now_playing_content_item WHERE account_id = NEW.account_id
        UNION
        SELECT 1 FROM now_playing_content_item_add_by_rss WHERE account_id = NEW.account_id
        UNION
        SELECT 1 FROM now_playing_content_item_chapter WHERE account_id = NEW.account_id
        UNION
        SELECT 1 FROM now_playing_content_clip WHERE account_id = NEW.account_id
        UNION
        SELECT 1 FROM now_playing_content_item_soundbite WHERE account_id = NEW.account_id
    ) THEN
        RAISE EXCEPTION 'account_id % already exists in another table', NEW.account_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_account_id_uniqueness_item
BEFORE INSERT ON now_playing_content_item
FOR EACH ROW EXECUTE FUNCTION check_account_id_uniqueness();

CREATE TRIGGER check_account_id_uniqueness_item_add_by_rss
BEFORE INSERT ON now_playing_content_item_add_by_rss
FOR EACH ROW EXECUTE FUNCTION check_account_id_uniqueness();

CREATE TRIGGER check_account_id_uniqueness_item_chapter
BEFORE INSERT ON now_playing_content_item_chapter
FOR EACH ROW EXECUTE FUNCTION check_account_id_uniqueness();

CREATE TRIGGER check_account_id_uniqueness_clip
BEFORE INSERT ON now_playing_content_clip
FOR EACH ROW EXECUTE FUNCTION check_account_id_uniqueness();

CREATE TRIGGER check_account_id_uniqueness_soundbite
BEFORE INSERT ON now_playing_content_item_soundbite
FOR EACH ROW EXECUTE FUNCTION check_account_id_uniqueness();

-- 0003 migration

CREATE TABLE clip (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES item(id) ON DELETE CASCADE,
    start_time media_player_time NOT NULL,
    end_time media_player_time,
    title varchar_normal,
    description varchar_long,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id)
);

CREATE INDEX idx_clip_account_id ON clip(account_id);
CREATE INDEX idx_clip_item_id ON clip(item_id);
CREATE INDEX idx_clip_sharable_status_id ON clip(sharable_status_id);

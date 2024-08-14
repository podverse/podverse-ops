CREATE TABLE clip (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    start_time numeric_20_11 NOT NULL,
    end_time numeric_20_11,
    title varchar_normal,
    description varchar_long,
    isPublic BOOLEAN DEFAULT FALSE
);

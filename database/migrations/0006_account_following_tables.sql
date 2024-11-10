-- 0006 migration

CREATE TABLE account_following_account (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    following_account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, following_account_id)
);

CREATE INDEX idx_account_following_account_account_id ON account_following_account(account_id);
CREATE INDEX idx_account_following_account_following_account_id ON account_following_account(following_account_id);

CREATE TABLE account_following_channel (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, channel_id)
);

CREATE INDEX idx_account_following_channel_account_id ON account_following_channel(account_id);
CREATE INDEX idx_account_following_channel_channel_id ON account_following_channel(channel_id);

CREATE TABLE account_following_playlist (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    playlist_id INTEGER NOT NULL REFERENCES playlist(id) ON DELETE CASCADE,
    PRIMARY KEY (account_id, playlist_id)
);

CREATE INDEX idx_account_following_playlist_account_id ON account_following_playlist(account_id);
CREATE INDEX idx_account_following_playlist_playlist_id ON account_following_playlist(playlist_id);

CREATE TABLE account_following_add_by_rss_channel (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    feed_url varchar_url NOT NULL,
    PRIMARY KEY (account_id, feed_url),
    title varchar_normal,
    image_url varchar_url
);

CREATE INDEX idx_account_following_add_by_rss_channel_account_id ON account_following_add_by_rss_channel(account_id);

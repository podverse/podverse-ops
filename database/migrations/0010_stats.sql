CREATE TABLE stats_track_account_guid (
    id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    account_guid UUID NOT NULL,
    updated_at server_time_with_default NOT NULL,
    UNIQUE (account_id),
    UNIQUE (account_guid),
    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE
);

CREATE INDEX stats_track_account_guid_account_id_idx ON stats_track_account_guid(account_id);
CREATE INDEX stats_track_account_guid_account_guid_idx ON stats_track_account_guid(account_guid);
CREATE INDEX stats_track_account_guid_updated_at_idx ON stats_track_account_guid(updated_at);

CREATE TABLE stats_track_event_channel (
    id SERIAL PRIMARY KEY,
    account_guid UUID NOT NULL,
    channel_id INT NOT NULL,
    created_at server_time_with_default NOT NULL,
    UNIQUE (account_guid, channel_id),
    FOREIGN KEY (account_guid) REFERENCES stats_track_account_guid(account_guid) ON DELETE CASCADE,
    FOREIGN KEY (channel_id) REFERENCES channel(id) ON DELETE CASCADE
);

CREATE INDEX stats_track_event_channel_account_guid_idx ON stats_track_event_channel(account_guid);
CREATE INDEX stats_track_event_channel_channel_id_idx ON stats_track_event_channel(channel_id);
CREATE INDEX stats_track_event_channel_created_at_idx ON stats_track_event_channel(created_at);

CREATE TABLE stats_aggregated_channel (
    id SERIAL PRIMARY KEY,
    channel_id INT NOT NULL,
    day_current_count INT NOT NULL DEFAULT 0,
    day_1_count INT NOT NULL DEFAULT 0,
    day_2_count INT NOT NULL DEFAULT 0,
    day_3_count INT NOT NULL DEFAULT 0,
    day_4_count INT NOT NULL DEFAULT 0,
    day_5_count INT NOT NULL DEFAULT 0,
    day_6_count INT NOT NULL DEFAULT 0,
    day_7_count INT NOT NULL DEFAULT 0,
    day_8_count INT NOT NULL DEFAULT 0,
    week_current_count INT NOT NULL DEFAULT 0,
    week_1_count INT NOT NULL DEFAULT 0,
    week_2_count INT NOT NULL DEFAULT 0,
    week_3_count INT NOT NULL DEFAULT 0,
    week_4_count INT NOT NULL DEFAULT 0,
    month_current_count INT NOT NULL DEFAULT 0,
    month_1_count INT NOT NULL DEFAULT 0,
    all_time_count INT NOT NULL DEFAULT 0,
    UNIQUE (channel_id),
    FOREIGN KEY (channel_id) REFERENCES channel(id) ON DELETE CASCADE
);

CREATE INDEX stats_aggregated_channel_channel_id_idx ON stats_aggregated_channel(channel_id);
CREATE INDEX stats_aggregated_channel_day_current_count_idx ON stats_aggregated_channel(day_current_count);
CREATE INDEX stats_aggregated_channel_week_current_count_idx ON stats_aggregated_channel(week_current_count);
CREATE INDEX stats_aggregated_channel_month_current_count_idx ON stats_aggregated_channel(month_current_count);
CREATE INDEX stats_aggregated_channel_all_time_count_idx ON stats_aggregated_channel(all_time_count);

CREATE TABLE stats_track_event_item (
    id SERIAL PRIMARY KEY,
    account_guid UUID NOT NULL,
    item_id INT NOT NULL,
    created_at server_time_with_default NOT NULL,
    UNIQUE (account_guid, item_id),
    FOREIGN KEY (account_guid) REFERENCES stats_track_account_guid(account_guid) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE
);

CREATE INDEX stats_track_event_item_account_guid_idx ON stats_track_event_item(account_guid);
CREATE INDEX stats_track_event_item_item_id_idx ON stats_track_event_item(item_id);
CREATE INDEX stats_track_event_item_created_at_idx ON stats_track_event_item(created_at);

CREATE TABLE stats_aggregated_item (
    id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    day_current_count INT NOT NULL DEFAULT 0,
    day_1_count INT NOT NULL DEFAULT 0,
    day_2_count INT NOT NULL DEFAULT 0,
    day_3_count INT NOT NULL DEFAULT 0,
    day_4_count INT NOT NULL DEFAULT 0,
    day_5_count INT NOT NULL DEFAULT 0,
    day_6_count INT NOT NULL DEFAULT 0,
    day_7_count INT NOT NULL DEFAULT 0,
    day_8_count INT NOT NULL DEFAULT 0,
    week_current_count INT NOT NULL DEFAULT 0,
    week_1_count INT NOT NULL DEFAULT 0,
    week_2_count INT NOT NULL DEFAULT 0,
    week_3_count INT NOT NULL DEFAULT 0,
    week_4_count INT NOT NULL DEFAULT 0,
    month_current_count INT NOT NULL DEFAULT 0,
    month_1_count INT NOT NULL DEFAULT 0,
    all_time_count INT NOT NULL DEFAULT 0,
    UNIQUE (item_id),
    FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE
);

CREATE INDEX stats_aggregated_item_item_id_idx ON stats_aggregated_item(item_id);
CREATE INDEX stats_aggregated_item_day_current_count_idx ON stats_aggregated_item(day_current_count);
CREATE INDEX stats_aggregated_item_week_current_count_idx ON stats_aggregated_item(week_current_count);
CREATE INDEX stats_aggregated_item_month_current_count_idx ON stats_aggregated_item(month_current_count);
CREATE INDEX stats_aggregated_item_all_time_count_idx ON stats_aggregated_item(all_time_count);

CREATE TABLE stats_track_event_clip (
    id SERIAL PRIMARY KEY,
    account_guid UUID NOT NULL,
    clip_id INT NOT NULL,
    created_at server_time_with_default NOT NULL,
    UNIQUE (account_guid, clip_id),
    FOREIGN KEY (account_guid) REFERENCES stats_track_account_guid(account_guid) ON DELETE CASCADE,
    FOREIGN KEY (clip_id) REFERENCES clip(id) ON DELETE CASCADE
);

CREATE INDEX stats_track_event_clip_account_guid_idx ON stats_track_event_clip(account_guid);
CREATE INDEX stats_track_event_clip_clip_id_idx ON stats_track_event_clip(clip_id);
CREATE INDEX stats_track_event_clip_created_at_idx ON stats_track_event_clip(created_at);

CREATE TABLE stats_aggregated_clip (
    id SERIAL PRIMARY KEY,
    clip_id INT NOT NULL,
    day_current_count INT NOT NULL DEFAULT 0,
    day_1_count INT NOT NULL DEFAULT 0,
    day_2_count INT NOT NULL DEFAULT 0,
    day_3_count INT NOT NULL DEFAULT 0,
    day_4_count INT NOT NULL DEFAULT 0,
    day_5_count INT NOT NULL DEFAULT 0,
    day_6_count INT NOT NULL DEFAULT 0,
    day_7_count INT NOT NULL DEFAULT 0,
    day_8_count INT NOT NULL DEFAULT 0,
    week_current_count INT NOT NULL DEFAULT 0,
    week_1_count INT NOT NULL DEFAULT 0,
    week_2_count INT NOT NULL DEFAULT 0,
    week_3_count INT NOT NULL DEFAULT 0,
    week_4_count INT NOT NULL DEFAULT 0,
    month_current_count INT NOT NULL DEFAULT 0,
    month_1_count INT NOT NULL DEFAULT 0,
    all_time_count INT NOT NULL DEFAULT 0,
    UNIQUE (clip_id),
    FOREIGN KEY (clip_id) REFERENCES clip(id) ON DELETE CASCADE
);

CREATE INDEX stats_aggregated_clip_clip_id_idx ON stats_aggregated_clip(clip_id);
CREATE INDEX stats_aggregated_clip_day_current_count_idx ON stats_aggregated_clip(day_current_count);
CREATE INDEX stats_aggregated_clip_week_current_count_idx ON stats_aggregated_clip(week_current_count);
CREATE INDEX stats_aggregated_clip_month_current_count_idx ON stats_aggregated_clip(month_current_count);
CREATE INDEX stats_aggregated_clip_all_time_count_idx ON stats_aggregated_clip(all_time_count);

CREATE TABLE stats_track_event_playlist (
    id SERIAL PRIMARY KEY,
    account_guid UUID NOT NULL,
    playlist_id INT NOT NULL,
    created_at server_time_with_default NOT NULL,
    UNIQUE (account_guid, playlist_id),
    FOREIGN KEY (account_guid) REFERENCES stats_track_account_guid(account_guid) ON DELETE CASCADE,
    FOREIGN KEY (playlist_id) REFERENCES playlist(id) ON DELETE CASCADE
);

CREATE INDEX stats_track_event_playlist_account_guid_idx ON stats_track_event_playlist(account_guid);
CREATE INDEX stats_track_event_playlist_playlist_id_idx ON stats_track_event_playlist(playlist_id);
CREATE INDEX stats_track_event_playlist_created_at_idx ON stats_track_event_playlist(created_at);

CREATE TABLE stats_aggregated_playlist (
    id SERIAL PRIMARY KEY,
    playlist_id INT NOT NULL,
    day_current_count INT NOT NULL DEFAULT 0,
    day_1_count INT NOT NULL DEFAULT 0,
    day_2_count INT NOT NULL DEFAULT 0,
    day_3_count INT NOT NULL DEFAULT 0,
    day_4_count INT NOT NULL DEFAULT 0,
    day_5_count INT NOT NULL DEFAULT 0,
    day_6_count INT NOT NULL DEFAULT 0,
    day_7_count INT NOT NULL DEFAULT 0,
    day_8_count INT NOT NULL DEFAULT 0,
    week_current_count INT NOT NULL DEFAULT 0,
    week_1_count INT NOT NULL DEFAULT 0,
    week_2_count INT NOT NULL DEFAULT 0,
    week_3_count INT NOT NULL DEFAULT 0,
    week_4_count INT NOT NULL DEFAULT 0,
    month_current_count INT NOT NULL DEFAULT 0,
    month_1_count INT NOT NULL DEFAULT 0,
    all_time_count INT NOT NULL DEFAULT 0,
    UNIQUE (playlist_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist(id) ON DELETE CASCADE
);

CREATE INDEX stats_aggregated_playlist_playlist_id_idx ON stats_aggregated_playlist(playlist_id);
CREATE INDEX stats_aggregated_playlist_day_current_count_idx ON stats_aggregated_playlist(day_current_count);
CREATE INDEX stats_aggregated_playlist_week_current_count_idx ON stats_aggregated_playlist(week_current_count);
CREATE INDEX stats_aggregated_playlist_month_current_count_idx ON stats_aggregated_playlist(month_current_count);
CREATE INDEX stats_aggregated_playlist_all_time_count_idx ON stats_aggregated_playlist(all_time_count);

CREATE TABLE stats_track_event_account (
    id SERIAL PRIMARY KEY,
    account_guid UUID NOT NULL,
    tracked_account_id INT NOT NULL,
    created_at server_time_with_default NOT NULL,
    UNIQUE (account_guid, tracked_account_id),
    FOREIGN KEY (account_guid) REFERENCES stats_track_account_guid(account_guid) ON DELETE CASCADE,
    FOREIGN KEY (tracked_account_id) REFERENCES account(id) ON DELETE CASCADE
);

CREATE INDEX stats_track_event_account_account_guid_idx ON stats_track_event_account(account_guid);
CREATE INDEX stats_track_event_account_tracked_account_id_idx ON stats_track_event_account(tracked_account_id);
CREATE INDEX stats_track_event_account_created_at_idx ON stats_track_event_account(created_at);

CREATE TABLE stats_aggregated_account (
    id SERIAL PRIMARY KEY,
    tracked_account_id INT NOT NULL,
    day_current_count INT NOT NULL DEFAULT 0,
    day_1_count INT NOT NULL DEFAULT 0,
    day_2_count INT NOT NULL DEFAULT 0,
    day_3_count INT NOT NULL DEFAULT 0,
    day_4_count INT NOT NULL DEFAULT 0,
    day_5_count INT NOT NULL DEFAULT 0,
    day_6_count INT NOT NULL DEFAULT 0,
    day_7_count INT NOT NULL DEFAULT 0,
    day_8_count INT NOT NULL DEFAULT 0,
    week_current_count INT NOT NULL DEFAULT 0,
    week_1_count INT NOT NULL DEFAULT 0,
    week_2_count INT NOT NULL DEFAULT 0,
    week_3_count INT NOT NULL DEFAULT 0,
    week_4_count INT NOT NULL DEFAULT 0,
    month_current_count INT NOT NULL DEFAULT 0,
    month_1_count INT NOT NULL DEFAULT 0,
    all_time_count INT NOT NULL DEFAULT 0,
    UNIQUE (tracked_account_id),
    FOREIGN KEY (tracked_account_id) REFERENCES account(id) ON DELETE CASCADE
);

CREATE INDEX stats_aggregated_account_tracked_account_id_idx ON stats_aggregated_account(tracked_account_id);
CREATE INDEX stats_aggregated_account_day_current_count_idx ON stats_aggregated_account(day_current_count);
CREATE INDEX stats_aggregated_account_week_current_count_idx ON stats_aggregated_account(week_current_count);
CREATE INDEX stats_aggregated_account_month_current_count_idx ON stats_aggregated_account(month_current_count);
CREATE INDEX stats_aggregated_account_all_time_count_idx ON stats_aggregated_account(all_time_count);

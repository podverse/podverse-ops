-- 0007

CREATE TABLE account_notification (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    PRIMARY KEY (channel_id, account_id)
);

CREATE INDEX idx_account_notification_channel_id ON account_notification(channel_id);
CREATE INDEX idx_account_notification_account_id ON account_notification(account_id);

CREATE TABLE account_up_device (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    up_endpoint varchar_url PRIMARY KEY,
    up_public_key varchar_long NOT NULL,
    up_auth_key varchar_long NOT NULL
);

CREATE INDEX idx_account_up_device_account_id ON account_up_device(account_id);

CREATE TABLE account_fcm_device (
    fcm_token varchar_fcm_token PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE
);

CREATE INDEX idx_account_fcm_device_account_id ON account_fcm_device(account_id);

-- 0007

CREATE TABLE account_notification (
    channel_id INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    PRIMARY KEY (channel_id, account_id),
    CONSTRAINT fk_channel FOREIGN KEY (channel_id) REFERENCES channel(id) ON DELETE CASCADE,
    CONSTRAINT fk_account FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE
);

CREATE TABLE account_up_device (
    account_id INTEGER NOT NULL,
    up_endpoint varchar_url PRIMARY KEY,
    up_public_key varchar_long NOT NULL,
    up_auth_key varchar_long NOT NULL,
    CONSTRAINT fk_account FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE
);

CREATE DOMAIN varchar_fcm_token AS VARCHAR(255);

CREATE TABLE account_fcm_device (
    fcm_token varchar_fcm_token PRIMARY KEY,
    account_id INT NOT NULL,
    CONSTRAINT fk_account FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE CASCADE
);

-- 0007

CREATE TABLE account_notification_channel (
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    PRIMARY KEY (channel_id, account_id)
);

CREATE INDEX idx_account_notification_channel_channel_id ON account_notification_channel(channel_id);
CREATE INDEX idx_account_notification_channel_account_id ON account_notification_channel(account_id);

CREATE TABLE account_up_device (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    up_endpoint varchar_url UNIQUE NOT NULL,
    up_public_key varchar_long NOT NULL,
    up_auth_key varchar_long NOT NULL
);

CREATE INDEX idx_account_up_device_account_id ON account_up_device(account_id);
CREATE INDEX idx_account_up_device_up_endpoint ON account_up_device(up_endpoint);

CREATE TABLE account_fcm_device (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    fcm_token varchar_fcm_token NOT NULL UNIQUE,
    installation_id varchar_guid NOT NULL UNIQUE,
    created_at server_time_with_default NOT NULL,
    updated_at server_time_with_default NOT NULL
);

CREATE TRIGGER set_updated_at_account_fcm_device
BEFORE UPDATE ON account_fcm_device
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_field();

CREATE INDEX idx_account_fcm_device_account_id ON account_fcm_device(account_id);
CREATE INDEX idx_account_fcm_device_fcm_token ON account_fcm_device(fcm_token);
CREATE INDEX idx_account_fcm_device_installation_id ON account_fcm_device(installation_id);

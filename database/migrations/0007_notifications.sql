-- 0007

CREATE TABLE account_notification_channel (
    id SERIAL PRIMARY KEY,
    channel_id INTEGER NOT NULL REFERENCES channel(id) ON DELETE CASCADE,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    UNIQUE (channel_id, account_id)
);

CREATE INDEX idx_account_notification_channel_channel_id ON account_notification_channel(channel_id);
CREATE INDEX idx_account_notification_channel_account_id ON account_notification_channel(account_id);

CREATE TYPE notification_channel_type_options AS ENUM ('new-item', 'livestream-scheduled', 'livestream-started');

CREATE TABLE account_notification_channel_type (
    id SERIAL PRIMARY KEY,
    account_notification_channel_id INTEGER NOT NULL REFERENCES account_notification_channel(id) ON DELETE CASCADE,
    type notification_channel_type_options NOT NULL
);

CREATE TABLE account_up_device (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    up_endpoint varchar_url UNIQUE NOT NULL,
    up_auth_key varchar_long,
    locale varchar_locale NOT NULL,
    created_at server_time_with_default NOT NULL,
    updated_at server_time_with_default NOT NULL,
    UNIQUE (account_id)
);

CREATE TRIGGER set_updated_at_account_up_device
BEFORE UPDATE ON account_up_device
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_field();

CREATE INDEX idx_account_up_device_account_id ON account_up_device(account_id);
CREATE INDEX idx_account_up_device_up_endpoint ON account_up_device(up_endpoint);

CREATE TYPE account_fcm_device_platform_options AS ENUM ('web','ios','android');

CREATE TABLE account_fcm_device (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    fcm_token varchar_fcm_token NOT NULL UNIQUE,
    installation_id varchar_guid NOT NULL UNIQUE,
    platform account_fcm_device_platform_options NOT NULL,
    locale varchar_locale NOT NULL,
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
CREATE INDEX idx_account_fcm_device_platform ON account_fcm_device(platform);

CREATE TABLE account_webpush_device (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    endpoint varchar_url NOT NULL UNIQUE,
    p256dh varchar_long NOT NULL,
    auth varchar_long NOT NULL,
    locale varchar_locale NOT NULL,
    created_at server_time_with_default NOT NULL,
    updated_at server_time_with_default NOT NULL
);

CREATE TRIGGER set_updated_at_account_webpush_device
BEFORE UPDATE ON account_webpush_device
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_field();

CREATE INDEX idx_account_webpush_device_account_id ON account_webpush_device(account_id);
CREATE INDEX idx_account_webpush_device_endpoint ON account_webpush_device(endpoint);

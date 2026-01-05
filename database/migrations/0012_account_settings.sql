CREATE TABLE account_settings (
    id SERIAL PRIMARY KEY,
    account_id integer NOT NULL REFERENCES account(id) ON DELETE CASCADE UNIQUE
);

CREATE TABLE account_settings_locale (
    id SERIAL PRIMARY KEY,
    account_settings_id integer NOT NULL REFERENCES account_settings(id) ON DELETE CASCADE UNIQUE,
    locale varchar_locale NOT NULL DEFAULT 'en-US'
);

CREATE TABLE account_settings_notification (
    id SERIAL PRIMARY KEY,
    account_settings_id integer NOT NULL REFERENCES account_settings(id) ON DELETE CASCADE UNIQUE
);

CREATE TABLE account_settings_notification_type (
    id SERIAL PRIMARY KEY,
    account_settings_notification_id INTEGER NOT NULL REFERENCES account_settings_notification(id) ON DELETE CASCADE,
    type notification_channel_type_options NOT NULL,
    CONSTRAINT account_settings_notification_type_notification_id_type_unique UNIQUE (account_settings_notification_id, type)
);

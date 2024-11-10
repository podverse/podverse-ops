-- 0000 migration

-- Helpers

-- In the previous version of the app, short_id was 7-14 characters long.
-- To make migration to v2 easier, we will use a 15 character long short_id,
-- so we can easily distinguish between v1 and v2 short_ids.
CREATE DOMAIN short_id_v2 AS VARCHAR(15);

CREATE DOMAIN varchar_short AS VARCHAR(50);
CREATE DOMAIN varchar_normal AS VARCHAR(255);
CREATE DOMAIN varchar_long AS VARCHAR(2500);

CREATE DOMAIN varchar_email AS VARCHAR(255) CHECK (VALUE ~ '^.+@.+\..+$');
CREATE DOMAIN varchar_fcm_token AS VARCHAR(255);
CREATE DOMAIN varchar_fqdn AS VARCHAR(253);
CREATE DOMAIN varchar_guid AS VARCHAR(36);
CREATE DOMAIN varchar_md5 AS VARCHAR(32);
CREATE DOMAIN varchar_password AS VARCHAR(36);
CREATE DOMAIN varchar_slug AS VARCHAR(100);
CREATE DOMAIN varchar_uri AS VARCHAR(2083);
CREATE DOMAIN varchar_url AS VARCHAR(2083) CHECK (VALUE ~ '^https?://|^http?://');

CREATE DOMAIN server_time AS TIMESTAMP;
CREATE DOMAIN server_time_with_default AS TIMESTAMP DEFAULT NOW();

CREATE DOMAIN media_player_time AS NUMERIC(10, 2);
CREATE DOMAIN list_position AS NUMERIC(22, 21);
CREATE DOMAIN numeric_20_11 AS NUMERIC(20, 11);

-- Function to set updated_at
CREATE OR REPLACE FUNCTION set_updated_at_field()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

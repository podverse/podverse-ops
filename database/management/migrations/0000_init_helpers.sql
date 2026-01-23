-- 0000 migration

-- Extensions

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Helpers (matching main database patterns)

-- In the previous version of the app, short_id was 7-14 characters long.
-- To make migration to v2 easier, we will use a 15 character long short_id,
-- so we can easily distinguish between v1 and v2 short_ids.
CREATE DOMAIN nano_id_v2 AS VARCHAR(15);

CREATE DOMAIN varchar_email AS VARCHAR(255) CHECK (VALUE ~ '^.+@.+\..+$');
-- bcrypt salted hash passwords are always 60 characters long
CREATE DOMAIN varchar_password AS VARCHAR(60);
CREATE DOMAIN server_time_with_default AS TIMESTAMP DEFAULT NOW();

-- Function to set updated_at
CREATE OR REPLACE FUNCTION set_updated_at_field()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

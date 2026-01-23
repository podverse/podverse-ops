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

-- 0001 migration

-- Admin Account Role Lookup Table (created before admin_account since it's referenced)
CREATE TABLE admin_account_role (
    id SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL UNIQUE CHECK (role IN ('superuser', 'admin')),
    created_at server_time_with_default,
    updated_at server_time_with_default
);

CREATE TRIGGER set_updated_at_admin_account_role
BEFORE UPDATE ON admin_account_role
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_field();

-- Seed the 2 roles
INSERT INTO admin_account_role (id, role) VALUES (1, 'superuser');
INSERT INTO admin_account_role (id, role) VALUES (2, 'admin');

-- Admin Account Table
CREATE TABLE admin_account (
    id SERIAL PRIMARY KEY,
    id_text nano_id_v2 UNIQUE NOT NULL,
    admin_account_role_id INTEGER NOT NULL DEFAULT 2 REFERENCES admin_account_role(id),
    created_at server_time_with_default,
    updated_at server_time_with_default
);

CREATE INDEX idx_admin_account_admin_account_role_id ON admin_account(admin_account_role_id);

CREATE TRIGGER set_updated_at_admin_account
BEFORE UPDATE ON admin_account
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_field();

-- Admin Account Credentials Table
CREATE TABLE admin_account_credentials (
    id SERIAL PRIMARY KEY,
    admin_account_id INTEGER NOT NULL REFERENCES admin_account(id) ON DELETE CASCADE UNIQUE,
    email varchar_email UNIQUE NOT NULL,
    password varchar_password NOT NULL
);

CREATE INDEX idx_admin_account_credentials_admin_account_id ON admin_account_credentials(admin_account_id);


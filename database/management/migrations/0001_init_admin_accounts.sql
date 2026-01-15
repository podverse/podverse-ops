-- 0001 migration

-- Admin Account Table
CREATE TABLE admin_account (
    id SERIAL PRIMARY KEY,
    id_text nano_id_v2 UNIQUE NOT NULL,
    created_at server_time_with_default,
    updated_at server_time_with_default
);

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

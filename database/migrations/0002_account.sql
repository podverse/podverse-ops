-- 0002 migration

CREATE TABLE sharable_status (
    id SERIAL PRIMARY KEY,
    status TEXT UNIQUE CHECK (status IN ('public', 'unlisted', 'private'))
);

INSERT INTO sharable_status (status) VALUES ('public'), ('unlisted'), ('private');

CREATE TABLE account (
    id SERIAL PRIMARY KEY,
    id_text short_id_v2 UNIQUE NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id)
);

CREATE INDEX idx_account_sharable_status_id ON account(sharable_status_id);

CREATE TABLE account_credentials (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    email varchar_email UNIQUE NOT NULL,
    password varchar_password NOT NULL
);

CREATE INDEX idx_account_credentials_account_id ON account_credentials(account_id);

CREATE TABLE account_profile (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    display_name varchar_normal,
    bio varchar_long
);

CREATE INDEX idx_account_profile_account_id ON account_profile(account_id);

CREATE TABLE account_reset_password (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    reset_token varchar_guid,
    reset_token_expires_at TIMESTAMP
);

CREATE INDEX idx_account_reset_password_account_id ON account_reset_password(account_id);

CREATE TABLE account_verification (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    verification_token varchar_guid,
    verification_token_expires_at TIMESTAMP
);

CREATE INDEX idx_account_verification_account_id ON account_verification(account_id);

CREATE TABLE account_membership (
    id SERIAL PRIMARY KEY,
    tier TEXT UNIQUE CHECK (tier IN ('trial', 'basic'))
);

INSERT INTO account_membership (tier) VALUES ('trial'), ('basic');

CREATE TABLE account_membership_status (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    account_membership_id INTEGER NOT NULL REFERENCES account_membership(id),
    membership_expires_at TIMESTAMP
);

CREATE INDEX idx_account_membership_status_account_id ON account_membership_status(account_id);
CREATE INDEX idx_account_membership_status_account_membership_id ON account_membership_status(account_membership_id);

CREATE TABLE account_admin_roles (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id) ON DELETE CASCADE,
    dev_admin BOOLEAN DEFAULT FALSE,
    podping_admin BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_account_admin_roles_account_id ON account_admin_roles(account_id);

CREATE TABLE sharable_status (
    id SERIAL PRIMARY KEY,
    status TEXT UNIQUE CHECK (status IN ('public', 'unlisted', 'private'))
);

INSERT INTO sharable_status (status) VALUES ('public'), ('unlisted'), ('private');

CREATE TABLE account (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    sharable_status_id INTEGER NOT NULL REFERENCES sharable_status(id)
);

CREATE TABLE account_credentials (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id),
    email varchar_email UNIQUE NOT NULL,
    password varchar_password NOT NULL
);

CREATE TABLE account_profile (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id),
    display_name varchar_normal,
    bio varchar_long
);

CREATE TABLE account_reset_password (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id),
    reset_token varchar_guid,
    reset_token_expires_at TIMESTAMP
);

CREATE TABLE account_verification (
    id SERIAL PRIMARY KEY,
    account_id integer REFERENCES account(id),
    verification_token varchar_guid,
    verification_token_expires_at TIMESTAMP
);

CREATE TABLE account_membership (
    id SERIAL PRIMARY KEY,
    tier TEXT UNIQUE CHECK (tier IN ('trial', 'basic'))
);

INSERT INTO account_membership (tier) VALUES ('trial'), ('basic');

CREATE TABLE account_membership_status (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id),
    account_membership_id INTEGER NOT NULL REFERENCES account_membership(id),
    membership_expires_at TIMESTAMP
);

CREATE TABLE account_admin_roles (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id),
    dev_admin BOOLEAN DEFAULT FALSE,
    podping_admin BOOLEAN DEFAULT FALSE
);

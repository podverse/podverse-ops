CREATE TABLE account (
    id SERIAL PRIMARY KEY,
    id_text short_id UNIQUE NOT NULL
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
    bio varchar_long,
    is_public BOOLEAN DEFAULT FALSE
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
    verification_token_expires_at TIMESTAMP,
    verified BOOLEAN DEFAULT FALSE
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

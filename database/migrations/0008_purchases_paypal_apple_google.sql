-- 0008

CREATE TABLE account_paypal_order (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    payment_id VARCHAR PRIMARY KEY,
    state VARCHAR
);

CREATE INDEX idx_account_paypal_order_account_id ON account_paypal_order(account_id);

CREATE TABLE account_app_store_purchase (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    transaction_id VARCHAR PRIMARY KEY,
    cancellation_date VARCHAR,
    cancellation_date_ms VARCHAR,
    cancellation_date_pst VARCHAR,
    cancellation_reason VARCHAR,
    expires_date VARCHAR,
    expires_date_ms VARCHAR,
    expires_date_pst VARCHAR,
    is_in_intro_offer_period BOOLEAN,
    is_trial_period BOOLEAN,
    original_purchase_date VARCHAR,
    original_purchase_date_ms VARCHAR,
    original_purchase_date_pst VARCHAR,
    original_transaction_id VARCHAR,
    product_id VARCHAR,
    promotional_offer_id VARCHAR,
    purchase_date VARCHAR,
    purchase_date_ms VARCHAR,
    purchase_date_pst VARCHAR,
    quantity INT,
    web_order_line_item_id VARCHAR
);

CREATE INDEX idx_account_app_store_purchase_account_id ON account_app_store_purchase(account_id);

CREATE TABLE account_google_play_purchase (
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    transaction_id VARCHAR PRIMARY KEY,
    acknowledgement_state INT NULL,
    consumption_state INT NULL,
    developer_payload VARCHAR NULL,
    kind VARCHAR NULL,
    product_id VARCHAR NOT NULL,
    purchase_time_millis VARCHAR NULL,
    purchase_state INT NULL,
    purchase_token VARCHAR UNIQUE NOT NULL
);

CREATE INDEX idx_account_google_play_purchase_account_id ON account_google_play_purchase(account_id);

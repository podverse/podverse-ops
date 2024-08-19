-- 0009

CREATE TABLE membership_claim_token (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claimed BOOLEAN DEFAULT FALSE,
    years_to_add INT DEFAULT 1,
    account_membership_id INT REFERENCES account_membership(id) ON DELETE CASCADE
);

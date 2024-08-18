-- 0009

CREATE TABLE account_claim_token (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claimed BOOLEAN DEFAULT FALSE,
    years_to_add INT DEFAULT 1
);

-- Seed script for local development admin account
-- Email: admin@podverse.fm
-- Password: Test!1Aa
-- This account is for local development convenience

-- To regenerate the hash if needed, run:
-- cd dev/local-utils && npm run generate-password-hash "Test!1Aa"

DO $$
DECLARE
    new_admin_account_id INTEGER;
    existing_admin_account_id INTEGER;
BEGIN
    -- Check if admin account already exists by email
    SELECT aac.admin_account_id INTO existing_admin_account_id 
    FROM admin_account_credentials aac 
    WHERE aac.email = 'admin@podverse.fm';

    IF existing_admin_account_id IS NOT NULL THEN
        RAISE NOTICE 'Local dev admin account already exists (id: %)', existing_admin_account_id;
        RETURN;
    END IF;

    -- Create admin account
    INSERT INTO admin_account (id_text)
    VALUES ('admindev000001')
    RETURNING id INTO new_admin_account_id;

    -- Create credentials
    -- Hash is for "Test!1Aa" with bcrypt cost 10
    INSERT INTO admin_account_credentials (admin_account_id, email, password)
    VALUES (
        new_admin_account_id,
        'admin@podverse.fm',
        '$2b$10$EhgpdpaFQooB.xrpHMdMBe.uJOBeuttpQOEcp1XG9EndaseZRoSee'
    );

    RAISE NOTICE 'Local dev admin account created: admin@podverse.fm / Test!1Aa (id: %)', new_admin_account_id;
END $$;

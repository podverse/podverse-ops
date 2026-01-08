-- Seed script for local development account
-- Email: localdev@podverse.fm
-- Password: Test!1Aa
-- This account is pre-verified for convenience

-- To regenerate the hash if needed, run:
-- cd dev/local-utils && npm run generate-password-hash "Test!1Aa"

DO $$
DECLARE
    new_account_id INTEGER;
    private_status_id INTEGER;
    existing_account_id INTEGER;
    trial_membership_id INTEGER;
    new_account_settings_id INTEGER;
    new_account_settings_notification_id INTEGER;
BEGIN
    -- Get private sharable_status id (default for new accounts)
    SELECT id INTO private_status_id FROM sharable_status WHERE status = 'private';

    -- Get trial membership id
    SELECT id INTO trial_membership_id FROM account_membership WHERE tier = 'trial';

    -- Check if account already exists by email
    SELECT ac.account_id INTO existing_account_id 
    FROM account_credentials ac 
    WHERE ac.email = 'localdev@podverse.fm';

    IF existing_account_id IS NOT NULL THEN
        RAISE NOTICE 'Local dev account already exists (id: %)', existing_account_id;
        RETURN;
    END IF;

    -- Create account with verified = true
    INSERT INTO account (id_text, verified, sharable_status_id)
    VALUES (
        'localdev00001',
        TRUE,
        private_status_id
    )
    RETURNING id INTO new_account_id;

    -- Create credentials
    -- Hash is for "Test!1Aa" with bcrypt cost 10
    INSERT INTO account_credentials (account_id, email, password)
    VALUES (
        new_account_id,
        'localdev@podverse.fm',
        '$2b$10$EhgpdpaFQooB.xrpHMdMBe.uJOBeuttpQOEcp1XG9EndaseZRoSee'
    );

    -- Create empty profile
    INSERT INTO account_profile (account_id)
    VALUES (new_account_id);

    -- Create membership status (trial, expires in 1 year for local dev convenience)
    INSERT INTO account_membership_status (account_id, account_membership_id, membership_expires_at)
    VALUES (
        new_account_id,
        trial_membership_id,
        NOW() + INTERVAL '1 year'
    );

    -- Create account settings
    INSERT INTO account_settings (account_id)
    VALUES (new_account_id)
    RETURNING id INTO new_account_settings_id;

    -- Create account settings locale
    INSERT INTO account_settings_locale (account_settings_id, locale)
    VALUES (new_account_settings_id, 'en-US');

    -- Create account settings notification
    INSERT INTO account_settings_notification (account_settings_id)
    VALUES (new_account_settings_id)
    RETURNING id INTO new_account_settings_notification_id;

    -- Create default notification types (new-item and livestream-started)
    INSERT INTO account_settings_notification_type (account_settings_notification_id, type)
    VALUES 
        (new_account_settings_notification_id, 'new-item'),
        (new_account_settings_notification_id, 'livestream-started');

    RAISE NOTICE 'Local dev account created: localdev@podverse.fm / Test!1Aa (id: %)', new_account_id;
END $$;

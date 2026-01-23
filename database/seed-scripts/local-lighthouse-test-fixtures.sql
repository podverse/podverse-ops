-- Seed script for Lighthouse test fixtures
-- Creates test feeds, channels, and items for performance testing
-- This script is idempotent (checks for existing data before creating)

DO $$
DECLARE
    feed_1_id INTEGER;
    feed_2_id INTEGER;
    feed_3_id INTEGER;
    channel_1_id INTEGER;
    channel_2_id INTEGER;
    channel_3_id INTEGER;
    item_1_id INTEGER;
    item_2_id INTEGER;
    item_3_id INTEGER;
    enclosure_1_id INTEGER;
    enclosure_2_id INTEGER;
    enclosure_3_id INTEGER;
    feed_flag_active_id INTEGER;
    podcast_medium_id INTEGER;
    video_medium_id INTEGER;
    music_medium_id INTEGER;
    item_flag_active_id INTEGER;
    podcast_index_id_1 INTEGER := 2147483640;
    podcast_index_id_2 INTEGER := 2147483641;
    podcast_index_id_3 INTEGER := 2147483642;
    existing_feed_id INTEGER;
BEGIN
    -- Get required IDs
    SELECT id INTO feed_flag_active_id FROM feed_flag_status WHERE status = 'active';
    SELECT id INTO podcast_medium_id FROM medium WHERE value = 'podcast';
    SELECT id INTO video_medium_id FROM medium WHERE value = 'video';
    SELECT id INTO music_medium_id FROM medium WHERE value = 'music';
    SELECT id INTO item_flag_active_id FROM item_flag_status WHERE status = 'active';

    -- Check if Feed 1 already exists
    SELECT id INTO existing_feed_id FROM feed WHERE podcast_index_id = podcast_index_id_1;
    IF existing_feed_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Feed 1 already exists (id: %)', existing_feed_id;
        SELECT id INTO feed_1_id FROM feed WHERE podcast_index_id = podcast_index_id_1;
    ELSE
        -- Create Feed 1 (Podcast)
        INSERT INTO feed (url, podcast_index_id, feed_flag_status_id)
        VALUES (
            'http://localhost:2111/feed-1.rss',
            podcast_index_id_1,
            feed_flag_active_id
        )
        RETURNING id INTO feed_1_id;

        -- Create feed_log for Feed 1
        INSERT INTO feed_log (feed_id, last_http_status, last_good_http_status_time)
        VALUES (feed_1_id, 200, NOW());

        RAISE NOTICE 'Created Lighthouse test Feed 1 (id: %, podcast_index_id: %)', feed_1_id, podcast_index_id_1;
    END IF;

    -- Check if Feed 2 already exists
    SELECT id INTO existing_feed_id FROM feed WHERE podcast_index_id = podcast_index_id_2;
    IF existing_feed_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Feed 2 already exists (id: %)', existing_feed_id;
        SELECT id INTO feed_2_id FROM feed WHERE podcast_index_id = podcast_index_id_2;
    ELSE
        -- Create Feed 2 (Video)
        INSERT INTO feed (url, podcast_index_id, feed_flag_status_id)
        VALUES (
            'http://localhost:2111/feed-2.rss',
            podcast_index_id_2,
            feed_flag_active_id
        )
        RETURNING id INTO feed_2_id;

        -- Create feed_log for Feed 2
        INSERT INTO feed_log (feed_id, last_http_status, last_good_http_status_time)
        VALUES (feed_2_id, 200, NOW());

        RAISE NOTICE 'Created Lighthouse test Feed 2 (id: %, podcast_index_id: %)', feed_2_id, podcast_index_id_2;
    END IF;

    -- Check if Feed 3 already exists
    SELECT id INTO existing_feed_id FROM feed WHERE podcast_index_id = podcast_index_id_3;
    IF existing_feed_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Feed 3 already exists (id: %)', existing_feed_id;
        SELECT id INTO feed_3_id FROM feed WHERE podcast_index_id = podcast_index_id_3;
    ELSE
        -- Create Feed 3 (Music)
        INSERT INTO feed (url, podcast_index_id, feed_flag_status_id)
        VALUES (
            'http://localhost:2111/feed-3.rss',
            podcast_index_id_3,
            feed_flag_active_id
        )
        RETURNING id INTO feed_3_id;

        -- Create feed_log for Feed 3
        INSERT INTO feed_log (feed_id, last_http_status, last_good_http_status_time)
        VALUES (feed_3_id, 200, NOW());

        RAISE NOTICE 'Created Lighthouse test Feed 3 (id: %, podcast_index_id: %)', feed_3_id, podcast_index_id_3;
    END IF;

    -- Check if Channel 1 already exists
    SELECT id INTO channel_1_id FROM channel WHERE id_text = 'lhtest-chan-1';
    IF channel_1_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Channel 1 already exists (id: %)', channel_1_id;
    ELSE
        -- Create Channel 1 (Podcast)
        INSERT INTO channel (id_text, feed_id, title, medium_id)
        VALUES (
            'lhtest-chan-1',
            feed_1_id,
            'Lighthouse Test Podcast',
            podcast_medium_id
        )
        RETURNING id INTO channel_1_id;

        -- Create channel_about
        INSERT INTO channel_about (channel_id, language)
        VALUES (channel_1_id, 'en');

        -- Create channel_image
        INSERT INTO channel_image (channel_id, url, image_width_size, is_resized)
        VALUES (channel_1_id, 'http://localhost:2111/chan-1-image.jpg', 1400, false);

        RAISE NOTICE 'Created Lighthouse test Channel 1 (id: %, id_text: lhtest-chan-1)', channel_1_id;
    END IF;

    -- Check if Channel 2 already exists
    SELECT id INTO channel_2_id FROM channel WHERE id_text = 'lhtest-chan-2';
    IF channel_2_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Channel 2 already exists (id: %)', channel_2_id;
    ELSE
        -- Create Channel 2 (Video)
        INSERT INTO channel (id_text, feed_id, title, medium_id)
        VALUES (
            'lhtest-chan-2',
            feed_2_id,
            'Lighthouse Test Video',
            video_medium_id
        )
        RETURNING id INTO channel_2_id;

        -- Create channel_about
        INSERT INTO channel_about (channel_id, language)
        VALUES (channel_2_id, 'en');

        -- Create channel_image
        INSERT INTO channel_image (channel_id, url, image_width_size, is_resized)
        VALUES (channel_2_id, 'http://localhost:2111/chan-2-image.jpg', 1400, false);

        RAISE NOTICE 'Created Lighthouse test Channel 2 (id: %, id_text: lhtest-chan-2)', channel_2_id;
    END IF;

    -- Check if Channel 3 already exists
    SELECT id INTO channel_3_id FROM channel WHERE id_text = 'lhtest-chan-3';
    IF channel_3_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Channel 3 already exists (id: %)', channel_3_id;
    ELSE
        -- Create Channel 3 (Music)
        INSERT INTO channel (id_text, feed_id, title, medium_id)
        VALUES (
            'lhtest-chan-3',
            feed_3_id,
            'Lighthouse Test Music',
            music_medium_id
        )
        RETURNING id INTO channel_3_id;

        -- Create channel_about
        INSERT INTO channel_about (channel_id, language)
        VALUES (channel_3_id, 'en');

        -- Create channel_image
        INSERT INTO channel_image (channel_id, url, image_width_size, is_resized)
        VALUES (channel_3_id, 'http://localhost:2111/chan-3-image.jpg', 1400, false);

        RAISE NOTICE 'Created Lighthouse test Channel 3 (id: %, id_text: lhtest-chan-3)', channel_3_id;
    END IF;

    -- Check if Item 1 already exists
    SELECT id INTO item_1_id FROM item WHERE id_text = 'lhtest-item-1';
    IF item_1_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Item 1 already exists (id: %)', item_1_id;
    ELSE
        -- Create Item 1 (Podcast Episode)
        INSERT INTO item (id_text, channel_id, title, guid, pub_date, item_flag_status_id)
        VALUES (
            'lhtest-item-1',
            channel_1_id,
            'Lighthouse Test Podcast Episode',
            'http://localhost:2111/feed-1.rss#lhtest-item-1',
            NOW(),
            item_flag_active_id
        )
        RETURNING id INTO item_1_id;

        -- Create item_description (required)
        INSERT INTO item_description (item_id, value)
        VALUES (item_1_id, 'Test podcast episode for Lighthouse performance testing.');

        -- Create item_image
        INSERT INTO item_image (item_id, url, image_width_size, is_resized)
        VALUES (item_1_id, 'http://localhost:2111/item-1-image.jpg', 1400, false);

        -- Create item_enclosure
        INSERT INTO item_enclosure (item_id, type, item_enclosure_default)
        VALUES (item_1_id, 'audio/mpeg', true)
        RETURNING id INTO enclosure_1_id;

        -- Create item_enclosure_source
        INSERT INTO item_enclosure_source (item_enclosure_id, uri, content_type)
        VALUES (enclosure_1_id, 'http://localhost:2111/item-1-podcast.mp3', 'audio/mpeg');

        RAISE NOTICE 'Created Lighthouse test Item 1 (id: %, id_text: lhtest-item-1)', item_1_id;
    END IF;

    -- Check if Item 2 already exists
    SELECT id INTO item_2_id FROM item WHERE id_text = 'lhtest-item-2';
    IF item_2_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Item 2 already exists (id: %)', item_2_id;
    ELSE
        -- Create Item 2 (Video Episode)
        INSERT INTO item (id_text, channel_id, title, guid, pub_date, item_flag_status_id)
        VALUES (
            'lhtest-item-2',
            channel_2_id,
            'Lighthouse Test Video Episode',
            'http://localhost:2111/feed-2.rss#lhtest-item-2',
            NOW(),
            item_flag_active_id
        )
        RETURNING id INTO item_2_id;

        -- Create item_description (required)
        INSERT INTO item_description (item_id, value)
        VALUES (item_2_id, 'Test video episode for Lighthouse performance testing.');

        -- Create item_image
        INSERT INTO item_image (item_id, url, image_width_size, is_resized)
        VALUES (item_2_id, 'http://localhost:2111/item-2-image.jpg', 1400, false);

        -- Create item_enclosure
        INSERT INTO item_enclosure (item_id, type, item_enclosure_default)
        VALUES (item_2_id, 'video/mp4', true)
        RETURNING id INTO enclosure_2_id;

        -- Create item_enclosure_source
        INSERT INTO item_enclosure_source (item_enclosure_id, uri, content_type)
        VALUES (enclosure_2_id, 'http://localhost:2111/item-2-video.mp4', 'video/mp4');

        RAISE NOTICE 'Created Lighthouse test Item 2 (id: %, id_text: lhtest-item-2)', item_2_id;
    END IF;

    -- Check if Item 3 already exists
    SELECT id INTO item_3_id FROM item WHERE id_text = 'lhtest-item-3';
    IF item_3_id IS NOT NULL THEN
        RAISE NOTICE 'Lighthouse test Item 3 already exists (id: %)', item_3_id;
    ELSE
        -- Create Item 3 (Music Track)
        INSERT INTO item (id_text, channel_id, title, guid, pub_date, item_flag_status_id)
        VALUES (
            'lhtest-item-3',
            channel_3_id,
            'Lighthouse Test Music Track',
            'http://localhost:2111/feed-3.rss#lhtest-item-3',
            NOW(),
            item_flag_active_id
        )
        RETURNING id INTO item_3_id;

        -- Create item_description (required)
        INSERT INTO item_description (item_id, value)
        VALUES (item_3_id, 'Test music track for Lighthouse performance testing.');

        -- Create item_image
        INSERT INTO item_image (item_id, url, image_width_size, is_resized)
        VALUES (item_3_id, 'http://localhost:2111/item-3-image.jpg', 1400, false);

        -- Create item_enclosure
        INSERT INTO item_enclosure (item_id, type, item_enclosure_default)
        VALUES (item_3_id, 'audio/mpeg', true)
        RETURNING id INTO enclosure_3_id;

        -- Create item_enclosure_source
        INSERT INTO item_enclosure_source (item_enclosure_id, uri, content_type)
        VALUES (enclosure_3_id, 'http://localhost:2111/item-3-music.mp3', 'audio/mpeg');

        RAISE NOTICE 'Created Lighthouse test Item 3 (id: %, id_text: lhtest-item-3)', item_3_id;
    END IF;

    RAISE NOTICE 'Lighthouse test fixtures setup complete!';
END $$;

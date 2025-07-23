-- Create export_logs table
CREATE TABLE export_logs (
    id SERIAL PRIMARY KEY,
    export_by TEXT NOT NULL,                             -- who triggered it (manually or via system)
    source TEXT NOT NULL CHECK (source IN ('channels', 'feeds', 'items')),
    filters JSONB,                                         -- optional, if search terms used (e.g., search, sort_by)
    status TEXT NOT NULL CHECK (status IN ('pending', 'success', 'failed', 'skipped', 'expired')),
    file_path TEXT,                                        -- absolute or relative file path
    format TEXT NOT NULL CHECK (format IN ('csv', 'json')),
    channels_count INTEGER,                                -- result count for channels (if present)
    feeds_count INTEGER,                                   -- result count for feeds (if present)
    items_count INTEGER,                                   -- result count for items (if present)
    created_at TIMESTAMP NOT NULL DEFAULT now(),           -- when task started
    completed_at TIMESTAMP,                                -- when task finished
    error_message TEXT                                     -- in case of failure
);

-- indexes for commonly queried fields
CREATE INDEX idx_export_logs_export_by ON export_logs(export_by);
CREATE INDEX idx_export_logs_source ON export_logs(source);
CREATE INDEX idx_export_logs_status ON export_logs(status);
CREATE INDEX idx_export_logs_created_at ON export_logs(created_at);
CREATE INDEX idx_export_logs_created_at_desc ON export_logs(created_at DESC);

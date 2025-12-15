CREATE TYPE on_demand_parser_event_type AS ENUM ('add', 'refresh', 'remoteItem');

CREATE TABLE on_demand_parser_event (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id) ON DELETE CASCADE,
    podcast_index_id INTEGER NOT NULL,
    remote_parent_podcast_index_id INTEGER,
    type on_demand_parser_event_type NOT NULL,
    created_at server_time_with_default NOT NULL
);

CREATE INDEX idx_on_demand_parser_event_account_id ON on_demand_parser_event(account_id);
CREATE INDEX idx_on_demand_parser_event_podcast_index_id ON on_demand_parser_event(podcast_index_id);
CREATE INDEX idx_on_demand_parser_event_remote_parent_podcast_index_id ON on_demand_parser_event(remote_parent_podcast_index_id);
CREATE INDEX idx_on_demand_parser_event_type ON on_demand_parser_event(type);
CREATE INDEX idx_on_demand_parser_event_created_at ON on_demand_parser_event(created_at DESC);

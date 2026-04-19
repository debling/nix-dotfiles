CREATE TABLE IF NOT EXISTS dhcp_leases (
    id SERIAL PRIMARY KEY,
    mac MACADDR NOT NULL UNIQUE,
    ip INET NOT NULL,
    hostname TEXT,
    supplied_hostname TEXT,
    client_id TEXT,
    vendor_class TEXT,
    user_class TEXT,
    requested_options TEXT,
    mud_url TEXT,
    interface TEXT,
    tags TEXT,
    expires_at TIMESTAMPTZ,
    last_seen TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dhcp_events (
    id SERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,
    mac MACADDR NOT NULL,
    ip INET,
    hostname TEXT,
    client_id TEXT,
    vendor_class TEXT,
    user_class TEXT,
    supplied_hostname TEXT,
    requested_options TEXT,
    mud_url TEXT,
    interface TEXT,
    tags TEXT,
    received_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_leases_mac ON dhcp_leases(mac);
CREATE INDEX IF NOT EXISTS idx_leases_ip ON dhcp_leases(ip);
CREATE INDEX IF NOT EXISTS idx_leases_hostname ON dhcp_leases(hostname);
CREATE INDEX IF NOT EXISTS idx_leases_vendor_class ON dhcp_leases(vendor_class);
CREATE INDEX IF NOT EXISTS idx_events_mac ON dhcp_events(mac);
CREATE INDEX IF NOT EXISTS idx_events_type ON dhcp_events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_received_at ON dhcp_events(received_at);
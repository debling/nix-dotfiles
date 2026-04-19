package main

import (
	"context"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

const dbURL = "postgresql://dhcp@/dhcp?host=/var/run/postgresql"

func env(key string) *string {
	v := os.Getenv(key)
	if v == "" || v == "*" {
		return nil
	}
	return &v
}

func parseExpiry(raw string) *time.Time {
	if raw == "" {
		return nil
	}
	ts, err := strconv.ParseInt(raw, 10, 64)
	if err != nil {
		return nil
	}
	t := time.Unix(ts, 0).UTC()
	return &t
}

func main() {
	if len(os.Args) < 4 {
		return
	}

	event := os.Args[1]
	mac := os.Args[2]
	ip := os.Args[3]

	var hostname *string
	if len(os.Args) > 4 && os.Args[4] != "*" {
		hostname = &os.Args[4]
	}

	suppliedHostname := env("DNSMASQ_SUPPLIED_HOSTNAME")
	clientID := env("DNSMASQ_CLIENT_ID")
	vendorClass := env("DNSMASQ_VENDOR_CLASS")
	userClass := env("DNSMASQ_USER_CLASS")
	requestedOptions := env("DNSMASQ_REQUESTED_OPTIONS")
	mudURL := env("DNSMASQ_MUD_URL")
	iface := env("DNSMASQ_INTERFACE")
	tags := env("DNSMASQ_TAGS")
	leaseExpiresVal := ""
	if v := env("DNSMASQ_LEASE_EXPIRES"); v != nil {
		leaseExpiresVal = *v
	}
	expiresAt := parseExpiry(leaseExpiresVal)

	switch event {
	case "add", "old":
	case "del":
	default:
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, dbURL)
	if err != nil {
		fmt.Fprintf(os.Stderr, "dhcp-event-hook: connect: %v\n", err)
		os.Exit(1)
	}
	defer pool.Close()

	if event == "add" || event == "old" {
		_, err = pool.Exec(ctx, `
			INSERT INTO dhcp_leases
				(mac, ip, hostname, supplied_hostname, client_id,
				 vendor_class, user_class, requested_options,
				 mud_url, interface, tags, expires_at, last_seen)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, NOW())
			ON CONFLICT (mac) DO UPDATE SET
				ip = EXCLUDED.ip,
				hostname = COALESCE(EXCLUDED.hostname, dhcp_leases.hostname),
				supplied_hostname = COALESCE(EXCLUDED.supplied_hostname, dhcp_leases.supplied_hostname),
				client_id = COALESCE(EXCLUDED.client_id, dhcp_leases.client_id),
				vendor_class = COALESCE(EXCLUDED.vendor_class, dhcp_leases.vendor_class),
				user_class = COALESCE(EXCLUDED.user_class, dhcp_leases.user_class),
				requested_options = COALESCE(EXCLUDED.requested_options, dhcp_leases.requested_options),
				mud_url = COALESCE(EXCLUDED.mud_url, dhcp_leases.mud_url),
				interface = COALESCE(EXCLUDED.interface, dhcp_leases.interface),
				tags = COALESCE(EXCLUDED.tags, dhcp_leases.tags),
				expires_at = EXCLUDED.expires_at,
				last_seen = NOW()
		`,
			mac, ip, hostname, suppliedHostname, clientID,
			vendorClass, userClass, requestedOptions,
			mudURL, iface, tags, expiresAt,
		)
	} else {
		_, err = pool.Exec(ctx, `DELETE FROM dhcp_leases WHERE mac = $1`, mac)
	}

	if err != nil {
		fmt.Fprintf(os.Stderr, "dhcp-event-hook: lease upsert: %v\n", err)
		os.Exit(1)
	}

	_, err = pool.Exec(ctx, `
		INSERT INTO dhcp_events
			(event_type, mac, ip, hostname, client_id, vendor_class,
			 user_class, supplied_hostname, requested_options,
			 mud_url, interface, tags)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
	`,
		event, mac, ip, hostname, clientID, vendorClass,
		userClass, suppliedHostname, requestedOptions,
		mudURL, iface, tags,
	)

	if err != nil {
		fmt.Fprintf(os.Stderr, "dhcp-event-hook: event insert: %v\n", err)
		os.Exit(1)
	}
}

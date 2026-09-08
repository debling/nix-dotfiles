/* See LICENSE file for copyright and license details. */

/* slstatus config for the dwm session (ThinkPad X1 Carbon).
 * dwm picks the output up from the root window name. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "n/a";

/* maximum output string length */
#define MAXLEN 2048

/*
 * function            description                     argument (example)
 *
 * battery_perc        battery percentage              battery name (BAT0)
 * battery_remaining   battery remaining HH:MM         battery name (BAT0)
 * battery_state       battery charging state          battery name (BAT0)
 * datetime            date and time                   format string (%F %T)
 * disk_free           free disk space in GB           mountpoint path (/)
 * ram_used            used memory in GB               NULL
 * run_command         custom shell command            command (echo foo)
 * wifi_essid          WiFi ESSID                      interface name (wlan0)
 * wifi_perc           WiFi signal in percent          interface name (wlan0)
 */
static const struct arg args[] = {
	/* function       format        argument */
	{ run_command,    " %s |",      "/run/current-system/sw/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume: //' | tr -d '\n'" },
	{ battery_state,  " %s",        "BAT0" },
	{ battery_perc,   "%s%%",       "BAT0" },
	{ battery_remaining, " (%s) |", "BAT0" },
	{ ram_used,       " %s |",      NULL },
	{ disk_free,      " %s |",      "/" },
	{ datetime,       " %s",        "%a %d %b %T" },
};

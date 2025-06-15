#!/bin/sh

set -x

SELECTION=$(rbw list --fields id,name | fuzzel --dmenu --with-nth=2 --accept-nth=1)

if rbw totp "$SELECTION"  >/dev/null 2>&1; then
    rbw totp "$SELECTION" | wl-copy --trim-newline
fi
rbw get "$SELECTION" | wl-copy --trim-newline

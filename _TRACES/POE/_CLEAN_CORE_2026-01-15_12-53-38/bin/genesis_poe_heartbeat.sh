#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

VAULT="$HOME/GENESIS/VAULT"
TRACES="$VAULT/_TRACES/POE"
mkdir -p "$TRACES"

DATE="$(date +%F)"
TS="$(date +%F_%H-%M-%S)"
HUMAN="$(date +'%F %H:%M:%S %Z')"
HOST="$(hostname 2>/dev/null || echo "host")"
UPTIME_S="$(cut -d. -f1 /proc/uptime 2>/dev/null || echo "0")"

TRACE_FILE="$TRACES/HEARTBEAT_${TS}.md"

cat > "$TRACE_FILE" <<MD
# POE HEARTBEAT
time: ${HUMAN}
date: ${DATE}
host: ${HOST}
uptime_s: ${UPTIME_S}

signal: alive
note: auto heartbeat (minimal trace)
MD

echo "OK :: HEARTBEAT -> file://${TRACE_FILE}"

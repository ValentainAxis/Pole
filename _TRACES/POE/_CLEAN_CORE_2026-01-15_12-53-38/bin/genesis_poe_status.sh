#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

VAULT="$HOME/GENESIS/VAULT"
TRACES="$VAULT/_TRACES/POE"
METRICS="$VAULT/_METRICS/poe_metrics.csv"
EXPORTS="$VAULT/_EXPORTS"

echo "=== GENESIS :: POE STATUS (lite) ==="
echo "METRICS -> file://$METRICS"
echo "TRACES  -> file://$TRACES"
echo "EXPORTS -> file://$EXPORTS"
echo

echo "=== TIMERS ==="
systemctl --user list-timers --all | grep -E "genesis-poe-(heartbeat|proof-week)" || true
echo

echo "=== METRICS TAIL ==="
tail -n 6 "$METRICS" 2>/dev/null || true
echo

echo "=== NEWEST HEARTBEATS ==="
ls -lt "$TRACES"/HEARTBEAT_*.md 2>/dev/null | head -n 8 || true
echo

echo "=== NEWEST EXPORTS ==="
ls -lt "$EXPORTS"/PROOF_POE_*.md 2>/dev/null | head -n 8 || true
echo

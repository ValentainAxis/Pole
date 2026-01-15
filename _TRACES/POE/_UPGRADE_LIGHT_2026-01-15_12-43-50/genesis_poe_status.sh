#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

VAULT="$HOME/GENESIS/VAULT"
METRICS="$VAULT/_METRICS/poe_metrics.csv"
TRACES="$VAULT/_TRACES/POE"
EXPORTS="$VAULT/_EXPORTS"

echo "=== GENESIS :: POE STATUS ==="
echo "METRICS -> file://$METRICS"
echo "TRACES  -> file://$TRACES"
echo "EXPORTS -> file://$EXPORTS"
echo

echo "=== TIMERS ==="
systemctl --user list-timers --all | grep -E "genesis-poe-(heartbeat|proof-week)" || true
echo

echo "=== LAST METRICS (tail) ==="
tail -n 5 "$METRICS" 2>/dev/null || echo "(metrics пока пустые)"
echo

echo "=== NEWEST TRACES ==="
ls -lt "$TRACES" 2>/dev/null | head -n 10 || true
echo

echo "=== NEWEST EXPORTS ==="
ls -lt "$EXPORTS" 2>/dev/null | head -n 10 || true
echo

echo "=== TIP (Calc) ==="
echo "Если Calc открыт до дописывания CSV — закрыть/открыть файл, и строки появятся."

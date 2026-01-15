#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

HEART="$HOME/GENESIS/bin/genesis_poe_heartbeat.sh"
PROOF="$HOME/GENESIS/bin/genesis_poe_proof_week.sh"

VAULT="$HOME/GENESIS/VAULT"
METRICS="$VAULT/_METRICS/poe_metrics.csv"
TRACES="$VAULT/_TRACES/POE"
EXPORTS="$VAULT/_EXPORTS"

mkdir -p "$VAULT/_METRICS" "$TRACES" "$EXPORTS"

# 0) быстрый “факт присутствия”: форс-удар heartbeat (если скрипт уже есть)
if [ -x "$HEART" ]; then
  bash "$HEART" >/dev/null 2>&1 || true
fi

# 1) systemd user: weekly proof
UNIT_DIR="$HOME/.config/systemd/user"
mkdir -p "$UNIT_DIR"

SERVICE="$UNIT_DIR/genesis-poe-proof-week.service"
TIMER="$UNIT_DIR/genesis-poe-proof-week.timer"

cat > "$SERVICE" <<EOF
[Unit]
Description=GENESIS POE Weekly Proof (export visible artifact)

[Service]
Type=oneshot
ExecStart=${PROOF}
EOF

cat > "$TIMER" <<'EOF'
[Unit]
Description=Run GENESIS POE Weekly Proof (export visible artifact)

[Timer]
OnCalendar=Mon *-*-* 12:25:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now genesis-poe-proof-week.timer

# 2) статус-скрипт (одна команда → всё видно)
STATUS="$HOME/GENESIS/bin/genesis_poe_status.sh"
cat > "$STATUS" <<'SH'
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
SH
chmod +x "$STATUS"

# 3) форс-прогон proof сейчас (чтобы артефакт появился сразу)
if [ -x "$PROOF" ]; then
  bash "$PROOF" >/dev/null 2>&1 || true
fi

echo
echo "READY ✅"
echo "STATUS   -> file://$STATUS"
echo "METRICS  -> file://$METRICS"
echo "TRACES   -> file://$TRACES"
echo "EXPORTS  -> file://$EXPORTS"
echo
echo "RUN:"
echo "  $STATUS"
echo
echo "OPEN:"
echo "  xdg-open \"$METRICS\""
echo "  xdg-open \"$TRACES\""
echo "  xdg-open \"$EXPORTS\""

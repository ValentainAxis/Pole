#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

HOME_DIR="${HOME}"
GENESIS_DIR="${HOME_DIR}/GENESIS"
VAULT_DIR="${GENESIS_DIR}/VAULT"
OPEN_DIR="${VAULT_DIR}/OPEN"
TRACES_DIR="${VAULT_DIR}/_TRACES/POE"
METRICS_DIR="${VAULT_DIR}/_METRICS"
EXPORTS_DIR="${VAULT_DIR}/_EXPORTS"
BIN_DIR="${GENESIS_DIR}/bin"

mkdir -p "${OPEN_DIR}" "${TRACES_DIR}" "${METRICS_DIR}" "${EXPORTS_DIR}" "${BIN_DIR}"

METRICS_CSV="${METRICS_DIR}/poe_metrics.csv"
HEART="${BIN_DIR}/genesis_poe_heartbeat.sh"

# 0) гарантируем CSV header
if [ ! -f "${METRICS_CSV}" ]; then
  cat > "${METRICS_CSV}" <<'CSV'
date,bot,sessions,messages,paywalls,subs,revenue_usd,note
CSV
fi

# 1) сам heartbeat-скрипт (пишет md + добавляет строку в csv)
cat > "${HEART}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

GENESIS_DIR="${HOME}/GENESIS"
VAULT_DIR="${GENESIS_DIR}/VAULT"
TRACES_DIR="${VAULT_DIR}/_TRACES/POE"
METRICS_CSV="${VAULT_DIR}/_METRICS/poe_metrics.csv"

mkdir -p "${TRACES_DIR}" "${VAULT_DIR}/_METRICS"

DATE="$(date +%F)"
TS="$(date +%F_%H-%M-%S)"
HUMAN="$(date +'%F %H:%M:%S %Z')"

HOST="$(hostname 2>/dev/null || echo "host")"
UPTIME_S="$(cut -d. -f1 /proc/uptime 2>/dev/null || echo "0")"

TRACE_FILE="${TRACES_DIR}/HEARTBEAT_${TS}.md"

cat > "${TRACE_FILE}" <<MD
# POE HEARTBEAT
time: ${HUMAN}
date: ${DATE}
host: ${HOST}
uptime_s: ${UPTIME_S}

signal: alive
note: auto heartbeat (minimal trace)
MD

# header если кто-то стёр файл
if [ ! -f "${METRICS_CSV}" ]; then
  echo "date,bot,sessions,messages,paywalls,subs,revenue_usd,note" > "${METRICS_CSV}"
fi

# минимальная строка (нулевые метрики + заметка о heartbeat)
NOTE="heartbeat:${TS};host:${HOST};uptime_s:${UPTIME_S}"
echo "${DATE},(auto),0,0,0,0,0,${NOTE}" >> "${METRICS_CSV}"

echo "OK :: HEARTBEAT -> file://${TRACE_FILE}"
echo "OK :: METRICS   -> file://${METRICS_CSV}"
SH
chmod +x "${HEART}"

# 2) systemd user timer (ежедневно + сразу после запуска сессии)
UNIT_DIR="${HOME}/.config/systemd/user"
mkdir -p "${UNIT_DIR}"

SERVICE="${UNIT_DIR}/genesis-poe-heartbeat.service"
TIMER="${UNIT_DIR}/genesis-poe-heartbeat.timer"

cat > "${SERVICE}" <<EOF
[Unit]
Description=GENESIS POE Heartbeat (minimal trace)

[Service]
Type=oneshot
ExecStart=${HEART}
EOF

cat > "${TIMER}" <<'EOF'
[Unit]
Description=Run GENESIS POE Heartbeat daily (minimal trace)

[Timer]
OnBootSec=2m
OnCalendar=*-*-* 12:20:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# 3) включаем и запускаем таймер
systemctl --user daemon-reload
systemctl --user enable --now genesis-poe-heartbeat.timer

# 4) первый запуск сразу, чтобы след появился мгновенно
"${HEART}" >/dev/null 2>&1 || true

echo
echo "READY ✅"
echo "HEART     -> file://${HEART}"
echo "SERVICE   -> file://${SERVICE}"
echo "TIMER     -> file://${TIMER}"
echo "METRICS   -> file://${METRICS_CSV}"
echo "TRACES    -> file://${TRACES_DIR}"
echo
echo "CHECK:"
echo "  systemctl --user status genesis-poe-heartbeat.timer --no-pager"
echo "  systemctl --user list-timers --all | grep -i heartbeat || true"
echo "  tail -n 3 \"${METRICS_CSV}\""
echo "  ls -lt \"${TRACES_DIR}\" | head -n 6"
echo
echo "OPEN:"
echo "  xdg-open \"${METRICS_CSV}\""
echo "  xdg-open \"${TRACES_DIR}\""

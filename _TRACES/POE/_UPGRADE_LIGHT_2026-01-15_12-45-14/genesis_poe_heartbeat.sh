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

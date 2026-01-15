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

read -r -p "BOT NAME: " BOT
read -r -p "SESSIONS (count): " SESSIONS
read -r -p "MESSAGES (count): " MESSAGES
read -r -p "PAYWALLS (count): " PAYWALLS
read -r -p "SUBS (count): " SUBS
read -r -p "REVENUE USD (number): " REV
read -r -p "NOTE (short): " NOTE

TRACE_FILE="${TRACES_DIR}/POE_${TS}.md"

cat > "${TRACE_FILE}" <<MD
# POE TRACE
time: ${HUMAN}
date: ${DATE}
bot: ${BOT}

sessions: ${SESSIONS}
messages: ${MESSAGES}
paywalls: ${PAYWALLS}
subs: ${SUBS}
revenue_usd: ${REV}

note:
${NOTE}
MD

[ -f "${METRICS_CSV}" ] || echo "date,bot,sessions,messages,paywalls,subs,revenue_usd,note" > "${METRICS_CSV}"

SAFE_NOTE="$(printf "%s" "${NOTE}" | sed 's/,/;/g')"
echo "${DATE},${BOT},${SESSIONS},${MESSAGES},${PAYWALLS},${SUBS},${REV},${SAFE_NOTE}" >> "${METRICS_CSV}"

echo
echo "OK :: TRACE   -> file://${TRACE_FILE}"
echo "OK :: METRICS -> file://${METRICS_CSV}"

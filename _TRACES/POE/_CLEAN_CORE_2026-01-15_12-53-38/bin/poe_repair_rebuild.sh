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

TS="$(date +%F_%H-%M-%S)"
REPAIR_DIR="${TRACES_DIR}/_REPAIR_${TS}"
mkdir -p "${REPAIR_DIR}"

METRICS_CSV="${METRICS_DIR}/poe_metrics.csv"
PROMPT_FILE="${OPEN_DIR}/poe_mirror_prompt.md"
LOGGER="${BIN_DIR}/genesis_poe_log.sh"
PROOF="${BIN_DIR}/genesis_poe_proof_week.sh"
RUNNER="${BIN_DIR}/genesis_poe.sh"

backup_if_present() { [ -e "$1" ] && cp -a "$1" "${REPAIR_DIR}/" 2>/dev/null || true; }

backup_if_present "${METRICS_CSV}"
backup_if_present "${PROMPT_FILE}"
backup_if_present "${LOGGER}"
backup_if_present "${PROOF}"
backup_if_present "${RUNNER}"

# 1) METRICS (clean CSV)
cat > "${METRICS_CSV}" <<'CSV'
date,bot,sessions,messages,paywalls,subs,revenue_usd,note
CSV

# 2) PROMPT
cat > "${PROMPT_FILE}" <<'MD'
# POE :: MIRROR (prompt)

Роль: зеркало формы мышления + катализатор следующего ясного шага.
Фокус: среда, ритм, след, проверяемый результат.

Формат ответа:
СЦЕНА: (что сейчас происходит в среде)
ШАГ: (одно действие на 3–7 минут, дающее след)
СЛЕД: (какой файл/артефакт появится)
МЕТРИКА: (одно число для записи)

Тон: бодрый, деловой, живой.
MD

# 3) LOGGER
cat > "${LOGGER}" <<'SH'
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
SH
chmod +x "${LOGGER}"

# 4) WEEK PROOF
cat > "${PROOF}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

GENESIS_DIR="${HOME}/GENESIS"
VAULT_DIR="${GENESIS_DIR}/VAULT"
METRICS_CSV="${VAULT_DIR}/_METRICS/poe_metrics.csv"
EXPORTS_DIR="${VAULT_DIR}/_EXPORTS"
mkdir -p "${EXPORTS_DIR}"

YEAR="$(date +%G)"
WEEK="$(date +%V)"
OUT="${EXPORTS_DIR}/PROOF_POE_${YEAR}-W${WEEK}.md"

[ -f "${METRICS_CSV}" ] || echo "date,bot,sessions,messages,paywalls,subs,revenue_usd,note" > "${METRICS_CSV}"

MON="$(date -d "today -$((10#$(date +%u)-1)) days" +%F)"
SUN="$(date -d "${MON} +6 days" +%F)"

awk -F',' -v mon="${MON}" -v sun="${SUN}" '
BEGIN{s=0;m=0;p=0;u=0;r=0;}
NR==1{next}
$1>=mon && $1<=sun{ s+=$3; m+=$4; p+=$5; u+=$6; r+=$7; }
END{ printf "%d %d %d %d %.2f\n", s,m,p,u,r; }
' "${METRICS_CSV}" > /tmp/poe_week_totals.$$ || true

read -r SESS MSG PAY SUB REV < /tmp/poe_week_totals.$$ || true
rm -f /tmp/poe_week_totals.$$

cat > "${OUT}" <<MD
# PROOF :: POE WEEK
week: ${YEAR}-W${WEEK}
range: ${MON} .. ${SUN}

totals:
- sessions: ${SESS}
- messages: ${MSG}
- paywalls: ${PAY}
- subs: ${SUB}
- revenue_usd: ${REV}

links:
- metrics: file://${METRICS_CSV}
- exports: file://${EXPORTS_DIR}

ritual:
1) открыть файл
2) выбрать 3 короткие строки “что сработало”
3) вынести в портфолио/пост как “след недели”
MD

echo
echo "OK :: PROOF -> file://${OUT}"
SH
chmod +x "${PROOF}"

# 5) RUNNER
cat > "${RUNNER}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
echo "GENESIS :: POE"
echo "1) log session:   $HOME/GENESIS/bin/genesis_poe_log.sh"
echo "2) proof (week):  $HOME/GENESIS/bin/genesis_poe_proof_week.sh"
echo
SH
chmod +x "${RUNNER}"

echo
echo "READY ✅"
echo "REPAIR  -> file://${REPAIR_DIR}"
echo "PROMPT  -> file://${PROMPT_FILE}"
echo "METRICS -> file://${METRICS_CSV}"
echo "TRACES  -> file://${TRACES_DIR}"
echo "EXPORTS -> file://${EXPORTS_DIR}"
echo
echo "Quick checks (live output):"
head -n 2 "${METRICS_CSV}" || true
sed -n '1,12p' "${PROMPT_FILE}" || true
head -n 5 "${LOGGER}" || true
head -n 5 "${PROOF}" || true

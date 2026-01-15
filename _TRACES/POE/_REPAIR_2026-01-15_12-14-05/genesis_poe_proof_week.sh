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

if [ ! -f "${METRICS_CSV}" ]; then
  echo "date,bot,sessions,messages,paywalls,subs,revenue_usd,note" > "${METRICS_CSV}"
fi

MON="$(date -d "today -$((10#$(date +%u)-1)) days" +%F)"
SUN="$(date -d "${MON} +6 days" +%F)"

awk -F',' -v mon="${MON}" -v sun="${SUN}" '
BEGIN{s=0;m=0;p=0;u=0;r=0;}
NR==1{next}
$1>=mon && $1<=sun{
  s+=$3; m+=$4; p+=$5; u+=$6; r+=$7;
}
END{printf "%d %d %d %d %.2f\n", s,m,p,u,r;}
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

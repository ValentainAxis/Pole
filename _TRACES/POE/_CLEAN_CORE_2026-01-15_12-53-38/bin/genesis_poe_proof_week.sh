#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

VAULT="$HOME/GENESIS/VAULT"
TRACES="$VAULT/_TRACES/POE"
METRICS="$VAULT/_METRICS/poe_metrics.csv"
EXPORTS="$VAULT/_EXPORTS"
mkdir -p "$TRACES" "$EXPORTS" "$VAULT/_METRICS"

YEAR="$(date +%G)"
WEEK="$(date +%V)"
OUT="$EXPORTS/PROOF_POE_${YEAR}-W${WEEK}.md"

[ -f "$METRICS" ] || echo "date,bot,sessions,messages,paywalls,subs,revenue_usd,note" > "$METRICS"

MON="$(date -d "today -$((10#$(date +%u)-1)) days" +%F)"
SUN="$(date -d "${MON} +6 days" +%F)"

HB_COUNT=0
HB_LAST=""

for i in 0 1 2 3 4 5 6; do
  d="$(date -d "${MON} +${i} days" +%F)"
  # count
  c="$(ls -1 "$TRACES"/HEARTBEAT_"${d}"_*.md 2>/dev/null | wc -l | tr -d ' ')"
  HB_COUNT="$((HB_COUNT + c))"
  # last (by mtime)
  last_today="$(ls -t "$TRACES"/HEARTBEAT_"${d}"_*.md 2>/dev/null | head -n 1 || true)"
  [ -n "${last_today}" ] && HB_LAST="${last_today}"
done

MET_TOT="$(awk -F',' -v mon="$MON" -v sun="$SUN" '
BEGIN{s=0;m=0;p=0;u=0;r=0;}
NR==1{next}
$1>=mon && $1<=sun{
  s+=$3; m+=$4; p+=$5; u+=$6; r+=$7;
}
END{ printf "%d %d %d %d %.2f\n", s,m,p,u,r; }
' "$METRICS" 2>/dev/null || true)"

SESS="$(printf "%s" "$MET_TOT" | awk '{print $1+0}')"
MSG="$(printf "%s" "$MET_TOT" | awk '{print $2+0}')"
PAY="$(printf "%s" "$MET_TOT" | awk '{print $3+0}')"
SUB="$(printf "%s" "$MET_TOT" | awk '{print $4+0}')"
REV="$(printf "%s" "$MET_TOT" | awk '{print $5+0}')"

cat > "$OUT" <<MD
# PROOF :: POE WEEK (autopilot-lite)
week: ${YEAR}-W${WEEK}
range: ${MON} .. ${SUN}

autopilot heartbeat:
- heartbeats: ${HB_COUNT}
- last_trace: ${HB_LAST}

real metrics (when you decide to feed them):
- sessions: ${SESS}
- messages: ${MSG}
- paywalls: ${PAY}
- subs: ${SUB}
- revenue_usd: ${REV}

links:
- traces:  file://${TRACES}
- metrics: file://${METRICS}
- exports: file://${EXPORTS}
MD

echo "OK :: PROOF -> file://${OUT}"

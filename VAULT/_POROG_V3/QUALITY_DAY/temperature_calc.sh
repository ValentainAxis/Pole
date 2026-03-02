#!/usr/bin/env bash
set -euo pipefail

# Args: ENERGY CLARITY PRESSURE CYCLE DISTORT
E="${1:-3}"
C="${2:-3}"
P="${3:-1}"
CY="${4:-OK}"
D="${5:-none}"

# base score
S=$(( E + C - P ))

# cycle correction
case "$CY" in
  OK|ok)     S=$((S+1)) ;;
  drift)     S=$((S-1)) ;;
  noisy)     S=$((S-2)) ;;
  sharp)     S=$((S-1)) ;;
  zero)      S=$((S+0)) ;;
  *)         : ;;
esac

# distortion correction (comma-separated)
IFS=',' read -ra parts <<< "$D"
for p in "${parts[@]}"; do
  p="${p//[[:space:]]/}"
  case "$p" in
    ""|none)       : ;;
    voice)         S=$((S-1)) ;;
    fatigue)       S=$((S-1)) ;;
    rush)          S=$((S-2)) ;;
    distraction)   S=$((S-1)) ;;
    *)             : ;;
  esac
done

# symbol mapping
SYM="≈"
if [[ "$CY" == "zero" ]]; then
  SYM="□"
elif (( S >= 7 )); then
  SYM="◎"
elif (( S >= 4 )); then
  SYM="○"
elif (( S >= 2 )); then
  SYM="~"
elif (( S >= 0 )); then
  SYM="≈"
else
  SYM="×"
fi

printf "%s" "$SYM"

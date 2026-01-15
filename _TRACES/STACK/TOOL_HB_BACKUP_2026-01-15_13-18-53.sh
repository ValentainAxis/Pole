#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

GENESIS="$HOME/GENESIS"
VAULT="$GENESIS/VAULT"
TRACES="$VAULT/_TRACES/STACK"
STATE_DIR="$VAULT/_STATE"
STATE="$STATE_DIR/tool_heartbeat.state"
LOCK="$STATE_DIR/.tool_heartbeat.lock"

mkdir -p "$TRACES" "$STATE_DIR"

# lock: один запуск в момент времени
command -v flock >/dev/null 2>&1 || true
exec 9>"$LOCK"
flock -n 9 || exit 0

TS_FILE="$(date +%F_%H-%M-%S)"
HUMAN="$(date +'%F %H:%M:%S %Z')"
OUT="$TRACES/TOOL_HEARTBEAT_${TS_FILE}.md"

have() { command -v "$1" >/dev/null 2>&1; }

verline() {
  local cmd="$1"
  shift || true
  # пробуем несколько типичных вариантов получения версии
  if "$cmd" --version >/dev/null 2>&1; then "$cmd" --version 2>/dev/null | head -n 1; return 0; fi
  if "$cmd" -v >/dev/null 2>&1; then "$cmd" -v 2>/dev/null | head -n 1; return 0; fi
  if "$cmd" version >/dev/null 2>&1; then "$cmd" version 2>/dev/null | head -n 1; return 0; fi
  if "$cmd" -V >/dev/null 2>&1; then "$cmd" -V 2>/dev/null | head -n 1; return 0; fi
  echo "version: unknown"
}

# список “костяка” (можно расширять позже без ломки)
TOOLS=(
  bash coreutils find sed awk grep
  git gh
  python3 pip3
  node npm
  rclone
  curl wget
  docker docker-compose podman
  ollama
  code
  blender godot
  ffmpeg
  xdg-open
)

tmp="$(mktemp)"
{
  echo "# tool|status|version"
  for t in "${TOOLS[@]}"; do
    if have "$t"; then
      v="$(verline "$t" | tr -d '\r' | sed 's/[[:space:]]\+/ /g' | sed 's/^ *//;s/ *$//')"
      echo "$t|present|$v"
    else
      echo "$t|absent|—"
    fi
  done
} > "$tmp"

# сортировка для стабильных диффов
sort -t'|' -k1,1 "$tmp" > "${tmp}.sorted"
mv -f "${tmp}.sorted" "$tmp"

# первый запуск = baseline как изменение
if [ ! -f "$STATE" ]; then
  cp -f "$tmp" "$STATE"
  {
    echo "# TOOL HEARTBEAT :: baseline"
    echo "time: $HUMAN"
    echo "vault: file://$VAULT"
    echo "state: file://$STATE"
    echo
    echo "delta: baseline established"
    echo
    echo "current:"
    echo
    echo '```text'
    sed -n '1,200p' "$STATE"
    echo '```'
  } > "$OUT"
  echo "OK ✅ baseline -> file://$OUT"
  exit 0
fi

# сравнение
if diff -q "$STATE" "$tmp" >/dev/null 2>&1; then
  # дельта отсутствует -> след не пишем
  rm -f "$tmp"
  exit 0
fi

# дельта есть -> пишем trace, обновляем state
{
  echo "# TOOL HEARTBEAT :: delta"
  echo "time: $HUMAN"
  echo "vault: file://$VAULT"
  echo "state: file://$STATE"
  echo
  echo "delta:"
  echo
  echo '```diff'
  diff -u "$STATE" "$tmp" | sed -n '1,240p'
  echo '```'
  echo
  echo "current (after):"
  echo
  echo '```text'
  sed -n '1,200p' "$tmp"
  echo '```'
} > "$OUT"

cp -f "$tmp" "$STATE"
rm -f "$tmp"

echo "OK ✅ delta -> file://$OUT"

#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

VAULT="$HOME/GENESIS/VAULT"
GARDEN="$VAULT/_GARDEN"
FRUITS="$GARDEN/FRUITS"
SEEDS="$GARDEN/SEEDS"
FOREST="$GARDEN/FOREST"
BIOMES="$GARDEN/BIOMES"

MARKET="$VAULT/_MARKET/POE"
EXPORTS="$VAULT/_EXPORTS"
POE_TRACES="$VAULT/_TRACES/POE"
STACK_DIR="$VAULT/_TRACES/STACK"

mkdir -p "$FOREST" "$BIOMES" "$FRUITS" "$SEEDS"

NOW="$(date +'%F %H:%M:%S %Z')"
YEAR="$(date +%G)"
WEEK="$(date +%V)"
STAMP="${YEAR}-W${WEEK}"

INDEX_MD="$FOREST/index.md"
INDEX_HTML="$FOREST/index.html"
CROSS="$FOREST/CROSSBREED_${STAMP}.md"

# helpers
lower() { tr '[:upper:]' '[:lower:]'; }

detect_biomes() {
  # stdin: text
  local t
  t="$(cat | lower)"
  local out=""
  echo "$t" | grep -qE "(poe|heartbeat_|proof_poe|_market/poe|_traces/poe)" && out="$out POE"
  echo "$t" | grep -qE "(obsidian|vault|книга|_garden|_traces/stack|stack_snapshot)" && out="$out BOOK"
  echo "$t" | grep -qE "(vs code|vscode|git|github|gh |repo|commit|кузниц)" && out="$out FORGE"
  echo "$t" | grep -qE "(blender|godot|scene|export|world|мир|ассет)" && out="$out WORLDS"
  echo "$t" | grep -qE "(здоров|движен|зарядк|сон|дых|пульс|спорт)" && out="$out HEALTH"
  echo "$t" | grep -qE "(философ|мантр|контакт|узнавани|смысл|духов)" && out="$out PHILOSOPHY"
  printf "%s\n" "$out" | awk '{$1=$1;print}'
}

# gather fruit files (public+internal) from latest baskets
FRUIT_FILES="$(find "$FRUITS" -maxdepth 2 -type f -name 'FRUIT_*_*.md' 2>/dev/null | sort || true)"

# reset biome indexes
for b in POE BOOK FORGE WORLDS HEALTH PHILOSOPHY HYBRIDS; do
  : > "$BIOMES/$b/index.md"
done

# forest index header
cat > "$INDEX_MD" <<MD
# GENESIS :: FOREST
time: $NOW
week: $STAMP

Карты:
- growth schema: file://$FOREST/SCHEMA_GROWTH.md
- market: file://$VAULT/_MARKET/POE
- fruits: file://$FRUITS
- seeds: file://$SEEDS
- biomes: file://$BIOMES

MD

# crossbreed collector (co-occurrence)
TMP_PAIRS="$(mktemp)"
TMP_TAGS="$(mktemp)"

# classify fruits
while read -r f; do
  [ -f "$f" ] || continue
  tags="$(cat "$f" | detect_biomes)"
  [ -n "$tags" ] || continue

  echo "$f|$tags" >> "$TMP_TAGS"

  for t in $tags; do
    echo "- $(basename "$(dirname "$f")") / $(basename "$f") -> file://$f" >> "$BIOMES/$t/index.md"
  done

  # co-occurrence pairs (for hybrid suggestions)
  for a in $tags; do
    for b in $tags; do
      [ "$a" = "$b" ] && continue
      echo "$a+$b" >> "$TMP_PAIRS"
    done
  done
done <<< "$FRUIT_FILES"

# biome sections in forest index
for b in POE BOOK FORGE WORLDS HEALTH PHILOSOPHY; do
  count="$(grep -c '^-' "$BIOMES/$b/index.md" 2>/dev/null || echo 0)"
  echo "## BIOME: $b ($count)" >> "$INDEX_MD"
  echo "file://$BIOMES/$b/index.md" >> "$INDEX_MD"
  echo >> "$INDEX_MD"
done

# crossbreed suggestions
sort "$TMP_PAIRS" | uniq -c | sort -nr > "$TMP_PAIRS.sorted" || true
{
  echo "# CROSSBREED :: $STAMP"
  echo "time: $NOW"
  echo
  echo "Скрещивание = ко-рост биомов в одном плоде. Чем чаще пара встречается, тем естественнее гибрид."
  echo
  echo "## Топ-пары"
  head -n 20 "$TMP_PAIRS.sorted" | while read -r n pair; do
    a="${pair%+*}"; b="${pair#*+}"
    echo "- [$n] $a × $b → HYBRID"
  done
  echo
  echo "## Идеи гибридов (название → обещание)"
  echo "- POE × BOOK → “Витрина, которая пишет в Книгу” (диалог → артефакты в VAULT)"
  echo "- BOOK × FORGE → “Книга с Кузницей” (заметки → репо-скелеты и повторяемость)"
  echo "- FORGE × WORLDS → “Миры под контролем” (Blender/Godot → экспорт + git-след)"
  echo "- HEALTH × PHILOSOPHY → “Тело как компас смысла” (ритуалы → ясность и устойчивость)"
  echo "- POE × FORGE → “Публичный бот с доказуемым кодом” (витрина → репозиторий)"
  echo "- WORLDS × PHILOSOPHY → “Эстетика как здоровье системы” (миры → форма мышления)"
} > "$CROSS"

echo "## CROSSBREED" >> "$INDEX_MD"
echo "file://$CROSS" >> "$INDEX_MD"
echo >> "$INDEX_MD"

# build simple HTML vitrina
{
  echo "<!doctype html><meta charset='utf-8'><title>GENESIS FOREST</title><body>"
  echo "<h1>GENESIS :: FOREST</h1>"
  echo "<p>time: $NOW &nbsp; week: $STAMP</p>"
  echo "<p><b>Schema:</b> <code>$FOREST/SCHEMA_GROWTH.md</code></p>"
  echo "<h2>Biomes</h2><ul>"
  for b in POE BOOK FORGE WORLDS HEALTH PHILOSOPHY; do
    count="$(grep -c '^-' "$BIOMES/$b/index.md" 2>/dev/null || echo 0)"
    echo "<li><b>$b</b> ($count) — <code>$BIOMES/$b/index.md</code></li>"
  done
  echo "</ul>"
  echo "<h2>Crossbreed</h2>"
  echo "<p><code>$CROSS</code></p>"
  echo "<h2>Roots</h2>"
  echo "<ul>"
  echo "<li><code>$FRUITS</code></li>"
  echo "<li><code>$SEEDS</code></li>"
  echo "<li><code>$VAULT/_MARKET/POE</code></li>"
  echo "</ul>"
  echo "</body>"
} > "$INDEX_HTML"

rm -f "$TMP_PAIRS" "$TMP_TAGS" "$TMP_PAIRS.sorted" 2>/dev/null || true

echo "OK ✅ FOREST INDEX -> file://$INDEX_MD"
echo "OK ✅ FOREST HTML  -> file://$INDEX_HTML"
echo "OK ✅ CROSSBREED   -> file://$CROSS"

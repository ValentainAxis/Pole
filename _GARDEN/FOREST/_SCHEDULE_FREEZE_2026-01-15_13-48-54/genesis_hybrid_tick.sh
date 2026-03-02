#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

VAULT="$HOME/GENESIS/VAULT"
GARDEN="$VAULT/_GARDEN"
FOREST="$GARDEN/FOREST"
SEEDS="$GARDEN/SEEDS"
BIOMES="$GARDEN/BIOMES"

mkdir -p "$SEEDS/HYBRIDS" "$BIOMES/HYBRIDS"

NOW="$(date +'%F %H:%M:%S %Z')"
YEAR="$(date +%G)"
WEEK="$(date +%V)"
STAMP="${YEAR}-W${WEEK}"

# pick latest crossbreed file
LATEST_CROSS="$(ls -t "$FOREST"/CROSSBREED_*.md 2>/dev/null | head -n 1 || true)"
[ -n "$LATEST_CROSS" ] || { echo "OK ✅ HYBRID: crossbreed missing"; exit 0; }

# extract first top-pair line: "- [N] A × B → HYBRID"
PAIR_LINE="$(awk '
  $0 ~ /^## Топ-пары/ {in=1; next}
  in==1 && $0 ~ /^- \[[0-9]+]/ {print; exit}
' "$LATEST_CROSS" 2>/dev/null || true)"

[ -n "$PAIR_LINE" ] || { echo "OK ✅ HYBRID: top-pair missing"; exit 0; }

# parse A and B
A="$(echo "$PAIR_LINE" | sed -E 's/^.*\] ([A-Z]+) × ([A-Z]+).*$/\1/')"
B="$(echo "$PAIR_LINE" | sed -E 's/^.*\] ([A-Z]+) × ([A-Z]+).*$/\2/')"

[ -n "$A" ] && [ -n "$B" ] || { echo "OK ✅ HYBRID: parse failed"; exit 0; }

OUT="$SEEDS/HYBRIDS/SEED_HYBRID_${STAMP}_${A}_${B}.md"

# idempotent: keep first created version per week/pair
if [ -f "$OUT" ]; then
  echo "OK ✅ HYBRID SEED already exists -> file://$OUT"
  exit 0
fi

cat > "$OUT" <<MD
# SEED :: HYBRID :: ${STAMP} :: ${A} × ${B}
time: ${NOW}

source_crossbreed: file://${LATEST_CROSS}
pair_line: ${PAIR_LINE}

## Обещание гибрида
Гибрид соединяет биомы **${A}** и **${B}** так, чтобы плод оставался проверяемым (артефакты) и переносимым (семечка).

## Мини-рецепт (как вырастить плод)
1) Взять по одному зрелому плоду из биома ${A} и ${B}.
2) Сохранить общий артефакт: один файл “FRUIT_PUBLIC” + один “SEED”.
3) Добавить “связку” (1–3 строки): что именно переносится из ${A} в ${B}.
4) Выпустить новый плод как HYBRID (в папку FRUITS/… и запись в BIOMES/HYBRIDS).

## Кому полезно
- тем, кто живёт между двумя мирами: ${A} и ${B}
- тем, кому нужен мост без потери чистоты слоёв

## Канон слияния
- Книга и Зеркало рядом, логика слоёв держится.
- Слияние только “ветви одного уровня”.
MD

# register in HYBRIDS biome index
echo "- ${STAMP} :: ${A}×${B} -> file://${OUT}" >> "$BIOMES/HYBRIDS/index.md" 2>/dev/null || true

echo "OK ✅ HYBRID SEED -> file://$OUT"
echo "OK ✅ HYBRIDS IDX -> file://$BIOMES/HYBRIDS/index.md"

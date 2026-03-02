# Git / Pole: контекст синхронизации (Genesis + mandry)

Этот документ фиксирует рабочий ритуал синхронизации локального репозитория с GitHub (ValentainAxis/Pole),
а также исправления типовых “поломок” git-конфига.

## База

- origin -> git@github.com:ValentainAxis/Pole.git
- Основная ветка: main
- LFS включён: аудио/текстуры трекаются через .gitattributes
- .godot/ (кэш Godot) должен быть в .gitignore

## Шаг 4: почистить мусор branch.main.remote / branch.main.merge

Симптом:
- warning: branch.main.remote имеет несколько значений
- warning: branch.main.merge имеет несколько значений

Лечение (оставить один upstream origin/main):

cd /home/arc/GENESIS/VAULT

echo "=== BEFORE (branch.main.*) ==="
git config --get-all branch.main.remote || true
git config --get-all branch.main.merge || true
echo

git config --unset-all branch.main.remote 2>/dev/null || true
git config --unset-all branch.main.merge 2>/dev/null || true

git config branch.main.remote origin
git config branch.main.merge refs/heads/main

echo
echo "=== AFTER (branch.main.*) ==="
git config --get-all branch.main.remote
git config --get-all branch.main.merge
echo

git status -sb
git remote -v

Ожидаемое: предупреждения про “несколько значений” исчезнут.

## Быстрый ритуал синхронизации

Перед работой:
git pull --rebase origin main
git lfs pull

После шага в Godot:
git add -A _WORKSPACES/mandry
git commit -m "mandry: <что сделал>"
git push origin main

## Alias wip (одна команда: add → commit → push)

cd /home/arc/GENESIS/VAULT

git config alias.wip '!f(){ msg="${1:-wip}"; \
  git update-index -q --refresh; \
  git diff --quiet && git diff --cached --quiet && { echo "No changes."; exit 0; }; \
  git add -A && git commit -m "$msg" && git push; \
}; f'

Использование:
git wip "mandry: something"

## Примечание про второй remote (imv/pole)

Если остались дополнительные remote (например imv) — они не мешают, но могут путать.
Когда убедились, что origin = Pole, можно удалить лишний remote:

git remote remove imv
git remote -v

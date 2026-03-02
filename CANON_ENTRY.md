# GENESIS :: CANON ENTRY POINT

STATUS: PAUSE / READY (нулевая точка зафиксирована)
DATE: 2026-01-18
ENV: Linux Mint + Terminal-first + VS Code + Agent-first
REPO: /home/arc/GENESIS/VAULT (ветка sigadefa)

## 0) Суть текущего состояния

VS Code установлен. Среда подготовлена, но агентные действия НЕ запускались.
Мы остановились сознательно до первого "боевого" шага.

## 1) Главная ось работы (канон)

НАМЕРЕНИЕ → ПЛАН → DIFF → ПРИЁМКА → TASK → СЛЕД

- НАМЕРЕНИЕ: человек формулирует цель словами
- ПЛАН: агент предлагает план действий
- DIFF: показываются изменения файлов
- ПРИЁМКА: человек Accept/Reject
- TASK: запуск команд через Tasks (как “органы агента”)
- СЛЕД: трассы/коммиты/артефакты в VAULT

## 2) Подготовленная “ДВЕРЬ” в VS Code

Workspace подготовлен:
- /home/arc/GENESIS/VAULT/_WORKSPACES/VSCODE_DOOR
- .vscode содержит: settings.json / tasks.json / extensions.json
- Cline установлен (UI виден), но НЕ включали работу агента намеренно

Открытие:
- скрипт: /home/arc/GENESIS/VAULT/_WORKSPACES/VSCODE_DOOR/_RUN/open_vscode_here.sh
- README: file:///home/arc/GENESIS/VAULT/_WORKSPACES/VSCODE_DOOR/README_DOOR.md

## 3) Ollama (база для локального режима)

Ollama предполагается как базовый режим (приватность/контроль).
Подключение к агенту ещё не выполнялось.

## 4) Что зафиксировано фактами

- SNAPSHOT_STATE.txt — технический снимок окружения (система, VS Code, workspace, ollama)
- _TRACES/_RECOVERY — следы восстановления git после проблем с объектами
- _TRACES/* — хроника, сиды, стек, vscodes notes и т.п.

## 5) Следующий безопасный шаг (НЕ выполнен)

1) Внутри VS Code: Trust workspace
2) Внутри Cline: выбрать provider (Ollama) и модель
3) Первый тест агента на “создать файл → diff → accept”
4) Первый task “Doctor” и запись результата в _TRACES

STOP HERE INTENTIONALLY.

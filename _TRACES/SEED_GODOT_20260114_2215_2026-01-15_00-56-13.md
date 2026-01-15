# MIRROR TRACE

- time: 2026-01-15 00:56:13 EET
- project: SEED_GODOT_20260114_2215
- mode: work
- backend: local
- in: /home/arc/GENESIS/VAULT/_OPEN/MIRROR_IN.md

## REQUEST

```
[MIRROR REQUEST]
time: 2026-01-15 00:56:13 EET
project: SEED_GODOT_20260114_2215
mode: work
backend: local

[START_SNIP]
# START — GENESIS

Это вход на сцену.
- Истина живёт в Vault и _TRACES.
- MIRROR — шлюз: поднимает контекст → спрашивает ИИ → пишет след.

## Памятки и Guardrails
- Godot keys (истина): file:///home/arc/GENESIS/VAULT/_CORE/_KEYS/GODOT_DEFAULT_KEYS.md
- Guardrails проекта (SEED_GODOT_20260114_2215): file:///home/arc/GENESIS/VAULT/_TRACES/SEED_GODOT_20260114_2215_GUARDRAILS.md

[PROJECT_TRACE_SNIP]
source: /home/arc/GENESIS/VAULT/_TRACES/SEED_GODOT_20260114_2215.md
# GENESIS SEED

Дата: 2026-01-14 22:15:08

## Что создано
- Проект: SEED_GODOT_20260114_2215
- Путь: /home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215
- Godot: /home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215/godot

## Вход (визуально)
- Рабочий стол: «GENESIS — SEED GODOT» / «GENESIS — SEED ПАПКА» / «GENESIS — SEED _TRACES»

## Ритм
- Один запуск → один след
- След живёт в _TRACES, проект живёт в PROJECTS

### Запуск SEED
- Время: 2026-01-14 22:21:22

### Truth: запуск Godot (системный бинарник)
- Время: 2026-01-14 23:56:28 EET
- Факт: wrapper ./godot в папке проекта отсутствует
- Запуск: /usr/local/bin/godot --path "/home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215/godot" --editor --scene "/home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215/godot/Main.tscn"
- Открыто: Main.tscn

### Факт: Main.tscn открыт в Godot
- Время: 2026-01-14 23:58:45 EET
- Подтверждение: открыт Main.tscn (узлы: Main → Label), режим 3D, Godot 4.3.stable
- Следующий узел: запуск сцены (кнопка ▶ / F5) как проверка пульса

### Пульс: сцена запущена (Play/F5)
- Время: 2026-01-15 00:01:24 EET
- Факт: открылось окно "GENESIS_SEED (DEBUG)"
- Наблюдение: серый фон, слева вертикально выводится текст "GENESIS SEED"
- Рендер: Vulkan / Forward+ / NVIDIA GeForce GTX 1050 Ti (по выводу редактора)

### Fix: задана геометрия Label (чтобы текст не складывался по буквам)
- Время: 2026-01-15 00:07:01 EET
- Изменение: Main.gd -> autowrap OFF + position(24,24) + size(1400,900)
- Проверка: Play/F5, текст читается строками (без вертикального столбика)

### Пульс: повторный запуск (стабильность подтверждена)
- Время: 2026-01-15 00:11:14 EET
- Действие: повторный Play/F5
- Наблюдение: окно DEBUG открывается, текст отображается блоком и читается строками

### Пульс 3D: Pulse3D.tscn запущена (Play/F5)
- Время: 2026-01-15 00:19:06 EET
- Наблюдение: в рантайм-окне виден куб; камера/свет работают; Label3D присутствует (если видно)

### 3D: добавлено вращение куба (Pulse3D.gd)
- Время: 2026-01-15 00:20:37 EET
- Изменение: _process -> rotate_y(delta * 0.8)
- Проверка: Play/F5, куб вращается

[FS_FACTS]
- project_dir: /home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215 (exists)
- scenes:
  - godot/Pulse3D.tscn
  - godot/Main.tscn

[GUARDRAILS_SNIP]
core:
# GODOT — Default editor shortcuts (source of truth)

Официальный список сочетаний клавиш (по версиям/языкам):
- RU: https://docs.godotengine.org/ru/4.x/tutorials/editor/default_key_mapping.html
- EN (stable): https://docs.godotengine.org/en/stable/tutorials/editor/default_key_mapping.html

Живое правило GENESIS:
- Истина по клавишам хранится тут.
- Локальная среда показывает то же самое в: Editor → Editor Settings → Shortcuts.

project:
# GUARDRAILS — SEED_GODOT_20260114_2215 (Godot)

time: 2026-01-15 00:34:06 EET
scope: editor keys + run switches + scene file traps + verified fixes
source: file:///home/arc/GENESIS/VAULT/_CORE/_KEYS/GODOT_DEFAULT_KEYS.md

## Ключевой переключатель запуска
- F5 = Run Project (main_scene проекта)
- F6 = Run Current Scene (текущая открытая сцена)
- F7 = Pause
- F8 = Stop
- Ctrl+Shift+P = Command Palette (быстрый поиск команд)

## Ловушки, которые уже проявились в проекте
- Симптом: “вращения нет” при открытой Pulse3D → причина: запускалась main_scene (F5) вместо текущей сцены → решение: F6 или назначение main_scene.
- Симптом: вертикальный текст в Main → причина: геометрия/ширина Label → решение: задать позицию+размер Label из Main.gd (facts already in trace).
- Симптом: Parse Error в Pulse3D.tscn на строке с mesh = BoxMesh.new() → причина: .tscn хранит ресурсы как SubResource/ExtResource → решение: BoxMesh как [sub_resource] + mesh = SubResource("id") + load_steps обновить.

## Факты (подтверждённые следом)
- Godot бинарник: /usr/local/bin/godot
- Проект живёт в: /home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215
- Main.tscn: пульс стабильный (текст читается блоком после фикса геометрии)
- Pulse3D.tscn: сцена открывается, куб/камера/свет присутствуют (после фикса SubResource)

## Как избегать повторов в разговорах с ИИ (контракт)
- Любое утверждение про “запуск” всегда уточняет: F5 (main_scene) или F6 (current scene).
- Любая правка сцены (.tscn) держит формат Godot: ресурсы → SubResource/ExtResource.
- Любая диагностика сначала печатает факты: путь проекта, наличие файлов, строка ошибки, строка файла.

[TASK]
Дай ОДИН следующий шаг по проекту как проверяемое действие для человека/среды.

Семантика трёх пунктов:
- WHAT_DONE = подтверждённые факты/состояние (артефакты, пути, наличие файлов, зафиксированные события из trace).
- WHAT_OPEN = неизвестные, которые влияют на выбор шага (если отсутствуют — так и напиши одной строкой).
- NEXT_STEP = ровно 1 проверяемое действие (команда/кнопка/экспорт/файл), которое человек выполнит дальше.

Пример WHAT_DONE (как “факты”):
- Проект SEED_GODOT_... создан, путь ... существует
- project.godot присутствует
- есть кнопки на рабочем столе (по trace)

[CONSTRAINTS]
Язык: русский.
Формат: строго 3 пункта (WHAT_DONE / WHAT_OPEN / NEXT_STEP).
Тон: деловой, коротко.
Правило истины: WHAT_DONE заполняется фактами из START/PROJECT_TRACE/FS_FACTS; фантазии и “я сделал” отсутствуют.

[LANGUAGE]
Ответ строго на русском языке. Если начал не по-русски — перепиши полностью по-русски.

[RESPONSE FORMAT — STRICT]
1) WHAT_DONE: confirmed facts/state from START_SNIP / PROJECT_TRACE_SNIP / FS_FACTS (2–8 коротких строк). If facts absent -> "Фактов пока мало."
2) WHAT_OPEN: unknowns affecting the next step (1–3 строки). If none -> "Параметры ясны."
3) NEXT_STEP: exactly ONE verifiable action for the human/environment (one command OR one button OR one export).
```

## RESPONSE

1) WHAT_DONE: Проект SEED_GODOT_20260114_2215 создан, путь /home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215 существует. Файл Pulse3D.tscn присутствует, текст в Main.tscn читается блоком после фикса геометрии Label.
2) WHAT_OPEN: Неизвестно параметры окружения (например, состояние позиции камеры или света в сцене Pulse3D).
3) NEXT_STEP: Наблюдение за поведением сцены Pulse3D.tscn при запуске F5. Проверка отсутствия ошибок и корректного рендеринга.


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

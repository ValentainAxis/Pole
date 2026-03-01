# MIRROR INPUT (one file = one session)

project: auto        # auto = latest SEED_GODOT_* from ~/GENESIS/PROJECTS
mode: work           # light | work | deep
backend: local       # auto | local | online

TASK:
<<<
Дай ОДИН следующий шаг по проекту как проверяемое действие для человека/среды.

Семантика трёх пунктов:
- WHAT_DONE = подтверждённые факты/состояние (артефакты, пути, наличие файлов, зафиксированные события из trace).
- WHAT_OPEN = неизвестные, которые влияют на выбор шага (если отсутствуют — так и напиши одной строкой).
- NEXT_STEP = ровно 1 проверяемое действие (команда/кнопка/экспорт/файл), которое человек выполнит дальше.

Пример WHAT_DONE (как “факты”):
- Проект SEED_GODOT_... создан, путь ... существует
- project.godot присутствует
- есть кнопки на рабочем столе (по trace)
>>>

CONSTRAINTS:
<<<
Язык: русский.
Формат: строго 3 пункта (WHAT_DONE / WHAT_OPEN / NEXT_STEP).
Тон: деловой, коротко.
Правило истины: WHAT_DONE заполняется фактами из START/PROJECT_TRACE/FS_FACTS; фантазии и “я сделал” отсутствуют.
Запуск сцены: использовать F6 (Run Current Scene), не F5.


>>>

extends Control

@onready var state_edit: LineEdit = $Root/StateEdit
@onready var step_edit: LineEdit = $Root/StepEdit
@onready var log: TextEdit = $Root/Log

@onready var pause_btn: Button = $Root/Buttons/PauseBtn
@onready var quieter_btn: Button = $Root/Buttons/QuieterBtn
@onready var noisier_btn: Button = $Root/Buttons/NoisierBtn
@onready var ask_btn: Button = $Root/Buttons/AskOllamaBtn
@onready var save_btn: Button = $Root/Buttons/SaveBtn

@onready var http: HTTPRequest = $HTTPRequest
@onready var pulse_timer: Timer = $PulseTimer

# Анти-спам: пульс пишет "Пауза." только если была тишина по действиям
var last_action_unix_sec: int = 0
const PULSE_MIN_IDLE_SEC: int = 20

# Чтобы "Пауза." не писалась бесконечно после достижения порога
var idle_pulse_already_logged: bool = false

func _ready() -> void:
	pause_btn.pressed.connect(_on_pause)
	quieter_btn.pressed.connect(_on_quieter)
	noisier_btn.pressed.connect(_on_noisier)
	ask_btn.pressed.connect(_on_ask_ollama)
	save_btn.pressed.connect(_on_save)

	http.request_completed.connect(_on_http_completed)
	pulse_timer.timeout.connect(_on_pulse)

	# Enter-удобства
	step_edit.text_submitted.connect(_on_step_submitted)
	state_edit.text_submitted.connect(_on_state_submitted)

	_mark_action()
	_log("Пауза.\nЯ вижу, что есть.\n(готов)")

func _mark_action() -> void:
	last_action_unix_sec = int(Time.get_unix_time_from_system())
	idle_pulse_already_logged = false

func _idle_seconds() -> int:
	return int(Time.get_unix_time_from_system()) - last_action_unix_sec

func _on_pulse() -> void:
	if _idle_seconds() >= PULSE_MIN_IDLE_SEC and not idle_pulse_already_logged:
		_log("Пауза.")
		idle_pulse_already_logged = true

func _on_state_submitted(_text: String) -> void:
	_mark_action()
	step_edit.grab_focus()

func _on_step_submitted(_text: String) -> void:
	_on_quieter()

func _on_pause() -> void:
	_mark_action()
	_log("Пауза.")
	state_edit.grab_focus()

func _on_quieter() -> void:
	_mark_action()
	var last_step := step_edit.text.strip_edges()
	_log("Тише — остаюсь.")
	if last_step != "":
		_log("Шаг подтверждён: " + last_step)

func _on_noisier() -> void:
	_mark_action()
	_log("Шум — пауза.")
	if step_edit.text.strip_edges().length() > 0:
		_log("Упростить шаг: оставь 1 действие (5–10 минут).")

func _on_ask_ollama() -> void:
	_mark_action()
	var state_txt := state_edit.text.strip_edges()
	var step_txt := step_edit.text.strip_edges()

	if state_txt == "" and step_txt == "":
		_log("Нечего отражать: заполни состояние или шаг.")
		return

	_log("Ollama: запрашиваю отражение…")

	# Быстрая модель для короткого протокола:
	var model_name := "llama3.2:3b-instruct-q4_K_M"
	# Если хочешь глубже — можно переключить на:
	# var model_name := "llama3.1:8b"

	var payload := {
		"model": model_name,
		"prompt": _build_prompt(state_txt, step_txt),
		"stream": false
	}

	var headers := PackedStringArray([
		"Content-Type: application/json"
	])

	var url := "http://127.0.0.1:11434/api/generate"
	var body := JSON.stringify(payload)

	var err := http.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		_log("Ошибка HTTPRequest: " + str(err))

func _build_prompt(state_txt: String, step_txt: String) -> String:
	# Уточняем: это "зеркало протокола", а не физическое зеркало.
	var p := ""
	p += "ROLE: Protocol Mirror\n"
	p += "TASK: Reflect ONLY the provided text state/step and suggest the tiniest next action.\n"
	p += "IMPORTANT:\n"
	p += "- Do NOT talk about mirrors, surfaces, bodies, or physical space.\n"
	p += "- No motivation. No empathy. No advice.\n"
	p += "- Output EXACTLY 2 lines.\n"
	p += "- Line1 starts with 'REFLECT: '\n"
	p += "- Line2 starts with 'STEP: '\n"
	p += "- Each line <= 120 chars.\n\n"

	if state_txt != "":
		p += "STATE: " + state_txt + "\n"
	if step_txt != "":
		p += "STEP_IN: " + step_txt + "\n"

	p += "\nFORMAT:\nREFLECT: ...\nSTEP: ..."
	return p

func _on_http_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		_log("Ollama: запрос не удался (result=" + str(result) + ")")
		return

	var txt := body.get_string_from_utf8()

	if response_code < 200 or response_code >= 300:
		_log("Ollama: HTTP " + str(response_code))
		_log("Ollama raw:\n" + txt)
		return

	var parsed = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		_log("Ollama: неожиданный JSON (не словарь)")
		_log("Ollama raw:\n" + txt)
		return

	var d := parsed as Dictionary
	var resp: String = str(d.get("response", "")).strip_edges()

	if resp == "":
		_log("Ollama: пустой response — печатаю raw для диагностики")
		_log("Ollama raw:\n" + txt)
		return

	_log("Ollama:\n" + resp)

func _on_save() -> void:
	_mark_action()

	var dir_user := "user://logs"
	var dir_abs := ProjectSettings.globalize_path(dir_user)
	DirAccess.make_dir_recursive_absolute(dir_abs)

	var file_abs := dir_abs.path_join("mindui_log.txt")

	var f := FileAccess.open(file_abs, FileAccess.WRITE)
	if f:
		f.store_string(log.text)
		_log("Сохранено: " + file_abs)
	else:
		_log("Ошибка сохранения: не удалось открыть файл")

func _log(message: String) -> void:
	var t := Time.get_datetime_string_from_system(false, true)
	log.text += "[" + t + "] " + message + "\n"
	log.scroll_vertical = log.get_line_count()

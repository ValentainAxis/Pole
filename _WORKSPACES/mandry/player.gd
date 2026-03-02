extends CharacterBody2D

@export var speed: float = 260.0

var near_hut: bool = false
var in_dialog: bool = false

const HINT_FAR: String = "Game: двигайся стрелками/WASD. Подойди к прямоугольнику."
const HINT_NEAR: String = "Ты подошёл к избушке. (Enter) постучать"

# ----------------------------
# Hint / подсказки
# ----------------------------
var hint_target_text: String = HINT_FAR
var hint_alpha: float = 1.0

var hint_reveal_mode: int = 0
@export var hint_normal_speed: float = 6.0
@export var hint_slow_speed: float = 2.5

const HINT_IDLE: int = 0
const HINT_FADE_OUT: int = 1
const HINT_FADE_IN: int = 2
var hint_phase: int = HINT_IDLE

var hint_pending_text: String = HINT_FAR
var hint_swap_done: bool = false
var hint_hold_hidden: bool = false

# ----------------------------
# Silence / молчание
# ----------------------------
@export var silence_hold_time: float = 1.2
@export var silence_fog_boost: float = 1.0
var silence_timer: float = 0.0
var silence_active: bool = false

# ----------------------------
# Fog / туман
# ----------------------------
var fog_alpha: float = 0.0
var fog_target_alpha: float = 0.0

@export var fog_near_base: float = 0.18
@export var fog_pulse_base_amp: float = 0.006
@export var fog_near_pulse_amp: float = 0.03
@export var fog_near_pulse_speed: float = 1.2
@export var fog_pulse_settle_time: float = 5.0

var fog_pulse_energy: float = 0.0

@export var fog_knock_boost: float = 0.10
@export var fog_knock_decay: float = 2.5
var fog_knock_energy: float = 0.0

@export var fog_enter_boost: float = 0.07
@export var fog_enter_decay: float = 2.0
var fog_enter_energy: float = 0.0

# ----------------------------
# Music / 3 слоя + кроссфейд
# ----------------------------
@export var music_muffle_db: float = -6.0

# базовая громкость всей музыки (общий тон)
@export var music_dark_db: float = -10.0
@export var music_neutral_db: float = -8.0
@export var music_bright_db: float = -6.0

# Насколько музыка слышна далеко от избушки:
# 1.0 = всегда одинаково по "плотности"
# 0.85 = дыхание поля (рекомендую)
@export_range(0.0, 1.0, 0.01) var music_far_gate: float = 0.85

# Минимальный уровень слоя (чтобы никогда не было "нулевой" тишины)
@export var music_layer_floor_db: float = -28.0

# Дополнительная прибавка рядом с избушкой (ощущение "входа")
@export var music_near_gain_db: float = 4.0

# скорость кроссфейда слоёв
@export var music_crossfade_speed: float = 1.8

# watchdog (если вдруг поток остановился)
@export var music_watchdog_interval: float = 1.0
var music_watchdog_timer: float = 0.0

var music_base_target_db: float = -8.0

var _music_low: AudioStreamPlayer = null
var _music_mid: AudioStreamPlayer = null
var _music_high: AudioStreamPlayer = null

var _music_low_target_db: float = -60.0
var _music_mid_target_db: float = -60.0
var _music_high_target_db: float = -60.0

# ----------------------------
# Dialog / задержка ответа
# ----------------------------
@export var dialog_delay_min: float = 0.25
@export var dialog_delay_max: float = 0.55

var dialog_wait_timer: float = 0.0
var waiting_for_dialog: bool = false
@export var freeze_player_in_dialog: bool = false

# ----------------------------
# Кто в избушке (характер)
# ----------------------------
@export_enum("Подозрительная", "Мудрая", "Нервная") var hut_personality: int = 0
@export_range(0.0, 1.0, 0.01) var hut_silence_chance: float = 0.18

const HUT_LINES_SUSPICIOUS: Array[String] = [
	"Кто там?..",
	"Шаги слышу. Кто идёт?",
	"Не люблю гостей...",
	"Зачем пришёл?..",
	"Скажи сразу — по делу ли?",
	"Хм. Опять кто-то стучит..."
]

const HUT_LINES_WISE: Array[String] = [
	"Я слышу тебя ещё до стука.",
	"Входят не ногами — намерением.",
	"Если пришёл — значит созрел.",
	"Слова скажешь — и мир ответит.",
	"Тише... не расплескай себя.",
	"Зачем пришёл — и что ищешь в себе?"
]

const HUT_LINES_NERVOUS: Array[String] = [
	"Эй! Кто там?!",
	"Сколько можно стучать!",
	"Опять ты?..",
	"Говори быстрее!",
	"Не люблю, когда подкрадываются.",
	"Фух... напугал."
]

const HUT_LINES_SPECIAL: Array[String] = [
	"Если ты слышишь тишину — ты уже внутри.",
	"Я не дверь. Я порог.",
	"Не спрашивай — вспомни.",
	"Ты идёшь верно. Просто не спеши.",
	"Смотри не глазами. Смотри полем.",
	"Ты принёс не просьбу — присутствие.",
	"Я вижу твою паузу. Она честнее слов."
]

@export var special_min_familiarity: float = 0.70
@export var special_base_chance: float = 0.06
@export var special_max_chance: float = 0.18
@export var special_irritation_penalty: float = 0.10
@export var special_cooldown: float = 22.0
@export var special_bonus_when_still: float = 0.06
var special_cooldown_timer: float = 0.0

var pending_dialog_text: String = ""
var pending_is_silence: bool = false

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# ----------------------------
# SFX: внутренний "тук"
# ----------------------------
var gen: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback

var time_passed: float = 0.0

# ----------------------------
# Cached nodes
# ----------------------------
var _fog_node: ColorRect = null
var _hint_node: Label = null
var _hut_visual: Polygon2D = null

# ----------------------------
# Memory / динамика реакции избушки
# ----------------------------
var knock_count_visit: int = 0
var hut_irritation: float = 0.0
var hut_familiarity: float = 0.0

@export var irritation_gain_per_knock: float = 0.22
@export var irritation_decay_per_sec: float = 0.18
@export var irritation_silence_bonus: float = 0.22
@export var irritation_dialog_delay_bonus: float = 0.10
@export var irritation_force_nervous_threshold: float = 0.85

@export var calm_speed_threshold: float = 8.0
@export var calm_decay_multiplier_when_still: float = 1.35

@export var familiarity_gain_per_sec_near_still: float = 0.10
@export var familiarity_gain_per_knock_polite: float = 0.02
@export var familiarity_decay_per_sec_far: float = 0.03
@export var familiarity_reduces_silence: float = 0.14
@export var familiarity_shifts_to_wise_threshold: float = 0.65

const META_HUT_IRRIT: String = "hut_irritation_mem"
const META_HUT_FAM: String = "hut_familiarity_mem"


func _ready() -> void:
	rng.randomize()

	_fog_node = _find_fog_node()
	_hint_node = _find_hint_node()
	_hut_visual = _find_hut_visual()

	_music_low = _find_music_player("MusicLow")
	_music_mid = _find_music_player("MusicMid")
	_music_high = _find_music_player("MusicHigh")

	_load_hut_session_memory()

	_set_hint(HINT_FAR, true)

	var scene: Node = get_tree().current_scene
	if scene:
		var hut_area: Node = scene.get_node_or_null("Hut/HutArea")
		if hut_area and hut_area is Area2D:
			(hut_area as Area2D).body_entered.connect(_on_hut_body_entered)
			(hut_area as Area2D).body_exited.connect(_on_hut_body_exited)

	_setup_sfx()
	_apply_fog(0.0)
	_setup_music_layers()


func _process(delta: float) -> void:
	time_passed += delta

	if special_cooldown_timer > 0.0:
		special_cooldown_timer = maxf(0.0, special_cooldown_timer - delta)

	_update_hint_fade(delta)
	_update_silence(delta)
	_update_fog(delta)
	_update_hut_pulse()
	_update_dialog_wait(delta)

	_update_hut_memory(delta)
	_update_music_base()
	_update_music_layers_crossfade(delta)
	_music_watchdog(delta)


func _physics_process(_delta: float) -> void:
	if freeze_player_in_dialog and in_dialog:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir: Vector2 = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if dir.length_squared() > 0.0:
		dir = dir.normalized()

	velocity = dir * speed
	move_and_slide()

	if near_hut and (not in_dialog) and (not waiting_for_dialog) and Input.is_action_just_pressed("ui_accept"):
		_on_interact()


# ----------------------------
# Hut memory update (irritation + familiarity)
# ----------------------------
func _update_hut_memory(delta: float) -> void:
	if not near_hut:
		hut_familiarity = lerp(hut_familiarity, 0.0, 1.0 - exp(-familiarity_decay_per_sec_far * delta))
		if hut_familiarity < 0.001:
			hut_familiarity = 0.0

		hut_irritation = lerp(hut_irritation, 0.0, 1.0 - exp(-irritation_decay_per_sec * 1.6 * delta))
		if hut_irritation < 0.001:
			hut_irritation = 0.0
		return

	var decay: float = irritation_decay_per_sec
	if velocity.length() < calm_speed_threshold:
		decay *= calm_decay_multiplier_when_still

	hut_irritation = lerp(hut_irritation, 0.0, 1.0 - exp(-decay * delta))
	if hut_irritation < 0.001:
		hut_irritation = 0.0

	if (not waiting_for_dialog) and velocity.length() < calm_speed_threshold:
		hut_familiarity = lerp(hut_familiarity, 1.0, 1.0 - exp(-familiarity_gain_per_sec_near_still * delta))
		if hut_familiarity > 0.999:
			hut_familiarity = 1.0


func _load_hut_session_memory() -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return

	if tree.has_meta(META_HUT_IRRIT):
		hut_irritation = clamp(float(tree.get_meta(META_HUT_IRRIT)), 0.0, 1.0)
	if tree.has_meta(META_HUT_FAM):
		hut_familiarity = clamp(float(tree.get_meta(META_HUT_FAM)), 0.0, 1.0)


func _save_hut_session_memory() -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	tree.set_meta(META_HUT_IRRIT, hut_irritation)
	tree.set_meta(META_HUT_FAM, hut_familiarity)


# ----------------------------
# Hut events
# ----------------------------
func _on_hut_body_entered(body: Node) -> void:
	if body != self:
		return

	near_hut = true
	in_dialog = false
	waiting_for_dialog = false

	knock_count_visit = 0

	_set_hint(HINT_NEAR)
	fog_target_alpha = fog_near_base

	fog_enter_energy = 1.0
	fog_pulse_energy = 1.0


func _on_hut_body_exited(body: Node) -> void:
	if body != self:
		return

	near_hut = false
	in_dialog = false
	waiting_for_dialog = false

	fog_knock_energy = 0.0
	fog_enter_energy = 0.0
	fog_pulse_energy = 0.0

	silence_active = false
	silence_timer = 0.0

	pending_dialog_text = ""
	pending_is_silence = false

	hint_hold_hidden = false
	_set_hint(HINT_FAR)

	fog_target_alpha = 0.0
	_set_hut_alpha(0.75)

	_save_hut_session_memory()


# ----------------------------
# Interact
# ----------------------------
func _on_interact() -> void:
	in_dialog = true
	waiting_for_dialog = true

	knock_count_visit += 1

	hut_irritation = clamp(hut_irritation + irritation_gain_per_knock, 0.0, 1.0)

	if hut_irritation < 0.55:
		hut_familiarity = clamp(hut_familiarity + familiarity_gain_per_knock_polite, 0.0, 1.0)

	var min_d: float = min(dialog_delay_min, dialog_delay_max)
	var max_d: float = max(dialog_delay_min, dialog_delay_max)

	var extra_delay: float = hut_irritation * irritation_dialog_delay_bonus
	dialog_wait_timer = rng.randf_range(min_d, max_d) + extra_delay

	var silence_chance: float = hut_silence_chance
	silence_chance += hut_irritation * irritation_silence_bonus
	silence_chance -= hut_familiarity * familiarity_reduces_silence
	silence_chance = clamp(silence_chance, 0.02, 0.95)

	pending_is_silence = rng.randf() < silence_chance

	if pending_is_silence:
		pending_dialog_text = ""
	else:
		var special_try: String = _maybe_pick_special_line()
		if special_try != "":
			pending_dialog_text = special_try
		else:
			pending_dialog_text = _pick_hut_line()

	_play_knock()
	fog_knock_energy = 1.0

	_hide_hint()


func _maybe_pick_special_line() -> String:
	if hut_familiarity < special_min_familiarity:
		return ""
	if special_cooldown_timer > 0.0:
		return ""
	if HUT_LINES_SPECIAL.size() == 0:
		return ""

	var t: float = inverse_lerp(special_min_familiarity, 1.0, hut_familiarity)
	t = clamp(t, 0.0, 1.0)

	var chance: float = lerp(special_base_chance, special_max_chance, t)

	if velocity.length() < calm_speed_threshold:
		chance += special_bonus_when_still

	chance -= hut_irritation * special_irritation_penalty
	chance = clamp(chance, 0.0, 0.95)

	if rng.randf() >= chance:
		return ""

	special_cooldown_timer = special_cooldown
	var idx: int = rng.randi_range(0, HUT_LINES_SPECIAL.size() - 1)
	return "Баба-Яга: " + HUT_LINES_SPECIAL[idx]


# ----------------------------
# Hint system (anti-flicker)
# ----------------------------
func _set_hint(t: String, instant: bool = false, allow_slow_reveal: bool = false) -> void:
	hint_target_text = t
	hint_pending_text = t
	hint_swap_done = false

	if allow_slow_reveal:
		hint_reveal_mode = 1

	if _hint_node == null:
		return

	if instant:
		hint_alpha = 1.0
		hint_phase = HINT_IDLE
		hint_reveal_mode = 0
		_apply_hint(t, 1.0)
		return

	hint_phase = HINT_FADE_OUT


func _hide_hint() -> void:
	if _hint_node == null:
		return
	hint_hold_hidden = true
	hint_swap_done = true
	hint_phase = HINT_FADE_OUT


func _update_hint_fade(delta: float) -> void:
	if _hint_node == null:
		return

	var sp_out: float = hint_normal_speed
	var sp_in: float = hint_slow_speed if hint_reveal_mode == 1 else hint_normal_speed

	if hint_phase == HINT_FADE_OUT:
		hint_alpha = lerp(hint_alpha, 0.0, 1.0 - exp(-sp_out * delta))

		if hint_alpha <= 0.03:
			if hint_hold_hidden:
				hint_alpha = 0.0
				hint_phase = HINT_IDLE
			else:
				if not hint_swap_done:
					hint_swap_done = true
					_apply_hint(hint_pending_text, 0.0)
				hint_phase = HINT_FADE_IN

	elif hint_phase == HINT_FADE_IN:
		hint_alpha = lerp(hint_alpha, 1.0, 1.0 - exp(-sp_in * delta))

		if hint_alpha >= 0.97:
			hint_alpha = 1.0
			hint_phase = HINT_IDLE
			hint_reveal_mode = 0

	var m: Color = _hint_node.modulate
	m.a = clamp(hint_alpha, 0.0, 1.0)
	_hint_node.modulate = m


func _apply_hint(t: String, a: float) -> void:
	if _hint_node == null:
		return

	_hint_node.text = t
	var m: Color = _hint_node.modulate
	m.a = clamp(a, 0.0, 1.0)
	_hint_node.modulate = m


# ----------------------------
# Dialog wait
# ----------------------------
func _update_dialog_wait(delta: float) -> void:
	if not waiting_for_dialog:
		return

	dialog_wait_timer -= delta
	if dialog_wait_timer > 0.0:
		return

	waiting_for_dialog = false
	hint_hold_hidden = false

	if pending_is_silence:
		in_dialog = false
		pending_is_silence = false
		pending_dialog_text = ""

		_apply_personality_silence()
		_set_hint("...", false, true)
		return

	_set_hint(pending_dialog_text if pending_dialog_text != "" else "...", false, true)


func _apply_personality_silence() -> void:
	silence_active = true

	var boost_scale: float = 1.0 + hut_irritation * 0.6
	boost_scale *= (1.0 - hut_familiarity * 0.25)

	match hut_personality:
		0:
			silence_timer = silence_hold_time * 1.5
			fog_enter_energy = silence_fog_boost * 1.4 * boost_scale
		1:
			silence_timer = silence_hold_time
			fog_enter_energy = silence_fog_boost * 0.6 * boost_scale
		2:
			silence_timer = silence_hold_time * 0.6
			fog_enter_energy = silence_fog_boost * 1.8 * boost_scale
			fog_knock_energy = maxf(fog_knock_energy, 0.35)


func _update_silence(delta: float) -> void:
	if not silence_active:
		return

	silence_timer -= delta
	if silence_timer > 0.0:
		return

	silence_active = false

	if near_hut:
		_set_hint(HINT_NEAR, false, true)
	else:
		_set_hint(HINT_FAR)


func _pick_hut_line() -> String:
	var personality_used: int = hut_personality

	if hut_irritation >= irritation_force_nervous_threshold:
		personality_used = 2
	elif hut_familiarity >= familiarity_shifts_to_wise_threshold and personality_used != 2:
		personality_used = 1

	var lines: Array[String]
	match personality_used:
		1:
			lines = HUT_LINES_WISE
		2:
			lines = HUT_LINES_NERVOUS
		_:
			lines = HUT_LINES_SUSPICIOUS

	if lines.size() == 0:
		return "Баба-Яга: ..."

	var idx: int = rng.randi_range(0, lines.size() - 1)
	return "Баба-Яга: " + lines[idx]


# ----------------------------
# Music: setup + crossfade by familiarity
# ----------------------------
func _setup_music_layers() -> void:
	_setup_music_player(_music_low, "res://audio/music/choir_low.ogg")
	_setup_music_player(_music_mid, "res://audio/music/choir_mid.ogg")
	_setup_music_player(_music_high, "res://audio/music/choir_high.ogg")

	_music_low_target_db = -60.0
	_music_mid_target_db = -60.0
	_music_high_target_db = -60.0


func _setup_music_player(player: AudioStreamPlayer, path: String) -> void:
	if player == null:
		return

	var res: Resource = load(path)
	if res == null:
		return
	if not (res is AudioStream):
		return

	var stream: AudioStream = res as AudioStream
	player.stream = stream

	if stream is AudioStreamOggVorbis:
		var ogg: AudioStreamOggVorbis = stream as AudioStreamOggVorbis
		ogg.loop = true
	elif stream is AudioStreamWAV:
		var w: AudioStreamWAV = stream as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD

	player.volume_db = -60.0
	player.play()


func _update_music_base() -> void:
	var base_db: float = _music_base_db_from_familiarity(hut_familiarity)

	# возле избушки: чуть приглушаем (комната) и при этом добавляем "приближение"
	if near_hut:
		base_db += music_muffle_db
		base_db += music_near_gain_db

	music_base_target_db = base_db

	var w_low: float = _weight_low(hut_familiarity)
	var w_mid: float = _weight_mid(hut_familiarity)
	var w_high: float = _weight_high(hut_familiarity)

	# нормализация, чтобы громкость не проваливалась при смене слоя
	var s: float = w_low + w_mid + w_high
	if s > 0.0001:
		w_low /= s
		w_mid /= s
		w_high /= s

	# gate: далеко не выключаем, а "дышим"
	var gate: float = 1.0 if near_hut else music_far_gate
	w_low *= gate
	w_mid *= gate
	w_high *= gate

	_music_low_target_db = music_base_target_db + _weight_to_db(w_low)
	_music_mid_target_db = music_base_target_db + _weight_to_db(w_mid)
	_music_high_target_db = music_base_target_db + _weight_to_db(w_high)


func _update_music_layers_crossfade(delta: float) -> void:
	var k: float = 1.0 - exp(-music_crossfade_speed * delta)

	if _music_low:
		_music_low.volume_db = lerp(_music_low.volume_db, _music_low_target_db, k)
	if _music_mid:
		_music_mid.volume_db = lerp(_music_mid.volume_db, _music_mid_target_db, k)
	if _music_high:
		_music_high.volume_db = lerp(_music_high.volume_db, _music_high_target_db, k)


func _music_watchdog(delta: float) -> void:
	music_watchdog_timer -= delta
	if music_watchdog_timer > 0.0:
		return
	music_watchdog_timer = maxf(0.1, music_watchdog_interval)

	if _music_low and _music_low.stream != null and (not _music_low.playing):
		_music_low.play()
	if _music_mid and _music_mid.stream != null and (not _music_mid.playing):
		_music_mid.play()
	if _music_high and _music_high.stream != null and (not _music_high.playing):
		_music_high.play()


func _music_base_db_from_familiarity(f: float) -> float:
	var ff: float = clamp(f, 0.0, 1.0)
	if ff < 0.5:
		var t1: float = ff / 0.5
		return lerp(music_dark_db, music_neutral_db, t1)
	else:
		var t2: float = (ff - 0.5) / 0.5
		return lerp(music_neutral_db, music_bright_db, t2)


func _weight_to_db(w: float) -> float:
	var ww: float = clamp(w, 0.0, 1.0)
	return lerp(music_layer_floor_db, 0.0, ww)


func _smoothstep(a: float, b: float, x: float) -> float:
	var t: float = clamp((x - a) / maxf(0.0001, (b - a)), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


func _weight_low(f: float) -> float:
	var ff: float = clamp(f, 0.0, 1.0)
	return 1.0 - _smoothstep(0.45, 0.55, ff)


func _weight_high(f: float) -> float:
	var ff: float = clamp(f, 0.0, 1.0)
	return _smoothstep(0.55, 0.70, ff)


func _weight_mid(f: float) -> float:
	var ff: float = clamp(f, 0.0, 1.0)
	var left: float = _smoothstep(0.25, 0.50, ff)
	var right: float = 1.0 - _smoothstep(0.55, 0.85, ff)
	return clamp(left * right, 0.0, 1.0)


# ----------------------------
# Fog
# ----------------------------
func _update_fog(delta: float) -> void:
	var speed_fade: float = 4.5
	fog_alpha = lerp(fog_alpha, fog_target_alpha, 1.0 - exp(-speed_fade * delta))

	if near_hut and fog_pulse_energy > 0.0:
		var settle_speed: float = 1.0 / maxf(0.05, fog_pulse_settle_time)
		fog_pulse_energy = lerp(fog_pulse_energy, 0.0, 1.0 - exp(-settle_speed * delta))
		if fog_pulse_energy < 0.01:
			fog_pulse_energy = 0.0

	if fog_knock_energy > 0.0:
		fog_knock_energy = lerp(fog_knock_energy, 0.0, 1.0 - exp(-fog_knock_decay * delta))
		if fog_knock_energy < 0.01:
			fog_knock_energy = 0.0

	if fog_enter_energy > 0.0:
		fog_enter_energy = lerp(fog_enter_energy, 0.0, 1.0 - exp(-fog_enter_decay * delta))
		if fog_enter_energy < 0.01:
			fog_enter_energy = 0.0

	var a: float = fog_alpha

	if near_hut:
		var phase: float = (sin(time_passed * TAU * fog_near_pulse_speed) + 1.0) * 0.5
		var smooth: float = phase * phase * (3.0 - 2.0 * phase)
		var centered: float = (smooth - 0.5) * 2.0

		var amp: float = fog_pulse_base_amp + fog_pulse_energy * fog_near_pulse_amp
		a += centered * amp

	a += fog_knock_energy * fog_knock_boost
	a += fog_enter_energy * fog_enter_boost

	_apply_fog(a)


func _apply_fog(a: float) -> void:
	if _fog_node == null:
		return

	_fog_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var c: Color = _fog_node.color
	c.a = clamp(a, 0.0, 0.6)
	_fog_node.color = c


# ----------------------------
# Hut pulse
# ----------------------------
func _update_hut_pulse() -> void:
	if not near_hut:
		return

	var phase: float = (sin(time_passed * TAU * fog_near_pulse_speed) + 1.0) * 0.5
	var smooth: float = phase * phase * (3.0 - 2.0 * phase)
	var centered: float = (smooth - 0.5) * 2.0

	var amp_visual: float = 0.012 + fog_pulse_energy * 0.06
	var a: float = 0.85 + centered * amp_visual
	a -= fog_knock_energy * 0.10
	_set_hut_alpha(a)


func _set_hut_alpha(a: float) -> void:
	if _hut_visual == null:
		return
	_hut_visual.modulate.a = clamp(a, 0.1, 1.0)


# ----------------------------
# SFX knock
# ----------------------------
func _setup_sfx() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return

	var sfx: Node = scene.get_node_or_null("Sfx")
	if sfx == null or not (sfx is AudioStreamPlayer):
		return

	gen = AudioStreamGenerator.new()
	gen.mix_rate = 44100
	gen.buffer_length = 0.2

	var player: AudioStreamPlayer = sfx as AudioStreamPlayer
	player.stream = gen
	player.play()

	playback = player.get_stream_playback() as AudioStreamGeneratorPlayback


func _play_knock() -> void:
	if playback == null:
		return

	var mix_rate: float = 44100.0
	var duration: float = 0.09
	var frames: int = int(mix_rate * duration)
	var freq: float = 140.0

	for i in range(frames):
		var t: float = float(i) / mix_rate
		var env: float = exp(-t * 35.0)
		var s: float = sin(TAU * freq * t) * env * 0.6
		playback.push_frame(Vector2(s, s))


# ----------------------------
# Node finders
# ----------------------------
func _find_fog_node() -> ColorRect:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return null

	var candidates: Array[String] = ["UI/UIRoot/Fog", "UI/Fog", "UIRoot/Fog", "Fog"]
	for p in candidates:
		var n: Node = scene.get_node_or_null(p)
		if n and n is ColorRect:
			return n as ColorRect
	return null


func _find_hint_node() -> Label:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return null

	var n: Node = scene.get_node_or_null("Hint")
	if n and n is Label:
		return n as Label
	return null


func _find_hut_visual() -> Polygon2D:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return null

	var n: Node = scene.get_node_or_null("Hut/HutVisual")
	if n and n is Polygon2D:
		return n as Polygon2D
	return null


func _find_music_player(node_name: String) -> AudioStreamPlayer:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return null
	var n: Node = scene.get_node_or_null(node_name)
	if n and n is AudioStreamPlayer:
		return n as AudioStreamPlayer
	return null

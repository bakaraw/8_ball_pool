extends Control
## Splash screen — animated game logo intro with "Press Any Key" prompt.

const MAIN_MENU_PATH := "res://scenes/home/main_menu.tscn"

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/VBoxContainer/SubtitleLabel
@onready var press_start_label: Label = $CenterContainer/VBoxContainer/PressStartLabel
@onready var eight_ball: Control = $CenterContainer/VBoxContainer/EightBallContainer
@onready var particles_rect: ColorRect = $ParticlesRect

var _can_skip := false
var _auto_timer: float = 0.0
var _transitioning := false

func _ready() -> void:
	# Hide everything initially
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	press_start_label.modulate.a = 0.0
	eight_ball.modulate.a = 0.0
	eight_ball.scale = Vector2(0.3, 0.3)

	# Start intro after a brief delay
	await get_tree().create_timer(0.3).timeout
	_play_intro()

func _play_intro() -> void:
	# 1. Fade in the 8-ball icon with a scale pop
	var ball_tween = create_tween()
	ball_tween.set_parallel(true)
	ball_tween.tween_property(eight_ball, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	ball_tween.tween_property(eight_ball, "scale", Vector2(1.0, 1.0), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await ball_tween.finished

	# 2. Fade in the title
	var title_tween = create_tween()
	title_tween.set_parallel(true)
	title_tween.tween_property(title_label, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
	title_tween.tween_property(title_label, "position:y", title_label.position.y, 0.6).from(title_label.position.y + 20).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await title_tween.finished

	# 3. Fade in subtitle
	var sub_tween = create_tween()
	sub_tween.tween_property(subtitle_label, "modulate:a", 0.6, 0.5).set_ease(Tween.EASE_OUT)
	await sub_tween.finished

	await get_tree().create_timer(0.3).timeout

	# 4. Show "Press Any Key" with pulse
	_can_skip = true
	_start_press_any_key_pulse()

func _start_press_any_key_pulse() -> void:
	var fade_in = create_tween()
	fade_in.tween_property(press_start_label, "modulate:a", 1.0, 0.4)
	await fade_in.finished

	# Looping pulse
	var pulse = create_tween().set_loops()
	pulse.tween_property(press_start_label, "modulate:a", 0.3, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(press_start_label, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _process(delta: float) -> void:
	if _can_skip:
		_auto_timer += delta
		if _auto_timer >= 5.0:
			_go_to_menu()

func _unhandled_input(event: InputEvent) -> void:
	if _can_skip and not _transitioning:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.pressed:
				_go_to_menu()

func _go_to_menu() -> void:
	if _transitioning:
		return
	_transitioning = true
	_can_skip = false
	SceneManager.change_scene(MAIN_MENU_PATH, SceneManager.TransitionType.FADE_BLACK, 0.6)

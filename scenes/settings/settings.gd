extends Control
## Dumb settings UI (visuals only, no backend functionality).

const MAIN_MENU_PATH := "res://scenes/home/main_menu.tscn"

# ── Node references ──────────────────────────────────────────────
@onready var tab_container: TabContainer = $MainPanel/VBoxContainer/TabContainer
@onready var back_button: Button = $MainPanel/VBoxContainer/ButtonRow/BackButton
@onready var apply_button: Button = $MainPanel/VBoxContainer/ButtonRow/ApplyButton
@onready var reset_button: Button = $MainPanel/VBoxContainer/ButtonRow/ResetButton

# Audio tab
@onready var master_slider: HSlider = $MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBox/MasterRow/MasterSlider
@onready var master_value: Label = $MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBox/MasterRow/MasterValue
@onready var music_slider: HSlider = $MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBox/MusicRow/MusicSlider
@onready var music_value: Label = $MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBox/MusicRow/MusicValue
@onready var sfx_slider: HSlider = $MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBox/SFXRow/SFXSlider
@onready var sfx_value: Label = $MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBox/SFXRow/SFXValue

# Display tab
@onready var resolution_option: OptionButton = $MainPanel/VBoxContainer/TabContainer/Display/ScrollContainer/VBox/ResolutionRow/ResolutionOption

# Controls tab
@onready var sensitivity_slider: HSlider = $MainPanel/VBoxContainer/TabContainer/Controls/ScrollContainer/VBox/SensitivityRow/SensitivitySlider
@onready var sensitivity_value: Label = $MainPanel/VBoxContainer/TabContainer/Controls/ScrollContainer/VBox/SensitivityRow/SensitivityValue

# Gameplay tab
@onready var difficulty_option: OptionButton = $MainPanel/VBoxContainer/TabContainer/Gameplay/ScrollContainer/VBox/DifficultyRow/DifficultyOption

func _ready() -> void:
	_setup_resolution_options()
	_setup_difficulty_options()
	_connect_signals()
	_style_all_buttons()
	_play_entrance()

# ── Setup ────────────────────────────────────────────────────────

func _setup_resolution_options() -> void:
	resolution_option.clear()
	resolution_option.add_item("1280 x 720", 0)
	resolution_option.add_item("1600 x 900", 1)
	resolution_option.add_item("1920 x 1080", 2)
	resolution_option.add_item("2560 x 1440", 3)
	resolution_option.select(0)

func _setup_difficulty_options() -> void:
	difficulty_option.clear()
	difficulty_option.add_item("Easy", 0)
	difficulty_option.add_item("Normal", 1)
	difficulty_option.add_item("Hard", 2)
	difficulty_option.select(1)

func _connect_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	apply_button.pressed.connect(_on_apply_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

	# Audio - UI only
	master_slider.value_changed.connect(func(v): master_value.text = "%d%%" % int(v * 100))
	music_slider.value_changed.connect(func(v): music_value.text = "%d%%" % int(v * 100))
	sfx_slider.value_changed.connect(func(v): sfx_value.text = "%d%%" % int(v * 100))

	# Controls - UI only
	sensitivity_slider.value_changed.connect(func(v): sensitivity_value.text = "%d%%" % int(v * 100))

# ── Apply / Reset / Back ─────────────────────────────────────────

func _on_apply_pressed() -> void:
	# Flash feedback
	var tween = create_tween()
	tween.tween_property(apply_button, "modulate", Color(0.4, 1.0, 0.4, 1.0), 0.15)
	tween.tween_property(apply_button, "modulate", Color(1, 1, 1, 1), 0.3)

func _on_reset_pressed() -> void:
	# Flash feedback
	var tween = create_tween()
	tween.tween_property(reset_button, "modulate", Color(1.0, 0.85, 0.4, 1.0), 0.15)
	tween.tween_property(reset_button, "modulate", Color(1, 1, 1, 1), 0.3)

func _on_back_pressed() -> void:
	if get_tree().current_scene == self:
		SceneManager.change_scene(MAIN_MENU_PATH, SceneManager.TransitionType.FADE_BLACK, 0.4)
	else:
		queue_free()

# ── Styling ──────────────────────────────────────────────────────

func _style_all_buttons() -> void:
	for btn in [back_button, apply_button, reset_button]:
		_style_button(btn)
		btn.mouse_entered.connect(_on_btn_hover.bind(btn))
		btn.mouse_exited.connect(_on_btn_unhover.bind(btn))
		btn.button_down.connect(_on_btn_press.bind(btn))
		btn.button_up.connect(_on_btn_release.bind(btn))

func _style_button(btn: Button) -> void:
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.08, 0.07, 0.12, 0.85)
	normal_style.border_color = Color(0.72, 0.58, 0.2, 0.6)
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(8)
	normal_style.set_content_margin_all(10)
	normal_style.content_margin_left = 24
	normal_style.content_margin_right = 24

	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.12, 0.1, 0.18, 0.95)
	hover_style.border_color = Color(0.92, 0.78, 0.35, 1.0)

	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.06, 0.05, 0.08, 0.95)
	pressed_style.border_color = Color(1.0, 0.85, 0.4, 1.0)

	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	btn.add_theme_stylebox_override("focus", normal_style)
	btn.add_theme_color_override("font_color", Color(0.85, 0.78, 0.6, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(0.98, 0.88, 0.45, 1.0))
	btn.add_theme_font_size_override("font_size", 16)

func _play_entrance() -> void:
	var panel = $MainPanel
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.95, 0.95)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# ── Hover / press animations ─────────────────────────────────────

func _on_btn_hover(btn: Button) -> void:
	create_tween().tween_property(btn, "scale", Vector2(1.04, 1.04), 0.12).set_ease(Tween.EASE_OUT)

func _on_btn_unhover(btn: Button) -> void:
	create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_ease(Tween.EASE_OUT)

func _on_btn_press(btn: Button) -> void:
	create_tween().tween_property(btn, "scale", Vector2(0.96, 0.96), 0.06).set_ease(Tween.EASE_IN)

func _on_btn_release(btn: Button) -> void:
	create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

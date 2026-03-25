extends Control
## Main menu with premium styling, button hover/click animations,
## staggered entrance animation, and ambient audio.

const GAMEPLAY_SCENE := "res://scenes/main/main.tscn"
const SETTINGS_SCENE := "res://scenes/settings/settings.tscn"

@onready var title_label: Label = $MenuPanel/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $MenuPanel/VBoxContainer/SubtitleLabel
@onready var button_container: VBoxContainer = $MenuPanel/VBoxContainer/ButtonContainer
@onready var bg_texture: TextureRect = $BackgroundTexture
@onready var vignette: ColorRect = $Vignette
@onready var menu_panel: PanelContainer = $MenuPanel
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer

var _buttons: Array[Button] = []

func _ready() -> void:
	_setup_buttons()
	# Hide everything until SceneManager's fade-in finishes
	menu_panel.modulate.a = 0.0
	# Wait for the transition to end, then play our entrance
	await get_tree().create_timer(0.7).timeout
	_play_entrance_animation()

func _setup_buttons() -> void:
	for child in button_container.get_children():
		if child is Button:
			_buttons.append(child)
			_style_button(child)
			child.mouse_entered.connect(_on_button_hover.bind(child))
			child.mouse_exited.connect(_on_button_unhover.bind(child))
			child.button_down.connect(_on_button_press.bind(child))
			child.button_up.connect(_on_button_release.bind(child))

	# Connect signals
	var play_btn = button_container.get_node("PlayButton")
	var settings_btn = button_container.get_node("SettingsButton")
	var quit_btn = button_container.get_node("QuitButton")
	var multi_btn = button_container.get_node("MultiplayerButton")

	play_btn.pressed.connect(_on_play_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	multi_btn.pressed.connect(_on_multiplayer_pressed)

func _style_button(btn: Button) -> void:
	# Create stylebox for normal state
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.08, 0.07, 0.12, 0.85)
	normal_style.border_color = Color(0.72, 0.58, 0.2, 0.6)
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(8)
	normal_style.set_content_margin_all(12)
	normal_style.content_margin_left = 40
	normal_style.content_margin_right = 40

	# Hover state
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.12, 0.1, 0.18, 0.95)
	hover_style.border_color = Color(0.92, 0.78, 0.35, 1.0)

	# Pressed state
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.06, 0.05, 0.08, 0.95)
	pressed_style.border_color = Color(1.0, 0.85, 0.4, 1.0)

	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	btn.add_theme_stylebox_override("focus", normal_style)

	btn.add_theme_color_override("font_color", Color(0.85, 0.78, 0.6, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(0.98, 0.88, 0.45, 1.0))
	btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.92, 0.55, 1.0))
	btn.add_theme_font_size_override("font_size", 20)

	# Store original scale for animations
	btn.pivot_offset = btn.size / 2.0

func _play_entrance_animation() -> void:
	# Animate menu panel sliding in from left
	menu_panel.modulate.a = 0.0
	menu_panel.position.x -= 60

	var panel_tween = create_tween()
	panel_tween.set_parallel(true)
	panel_tween.tween_property(menu_panel, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
	panel_tween.tween_property(menu_panel, "position:x", menu_panel.position.x + 60, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# ── Button hover/click animations ────────────────────────────────

func _on_button_hover(btn: Button) -> void:
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_button_unhover(btn: Button) -> void:
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_button_press(btn: Button) -> void:
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.08).set_ease(Tween.EASE_IN)

func _on_button_release(btn: Button) -> void:
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# ── Button callbacks ─────────────────────────────────────────────

func _on_play_pressed() -> void:
	SceneManager.change_scene_with_loading(GAMEPLAY_SCENE, SceneManager.TransitionType.FADE_BLACK, 0.5)

func _on_settings_pressed() -> void:
	SceneManager.change_scene(SETTINGS_SCENE, SceneManager.TransitionType.FADE_BLACK, 0.4)

func _on_multiplayer_pressed() -> void:
	# Future: lobby screen
	pass

func _on_quit_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().quit()

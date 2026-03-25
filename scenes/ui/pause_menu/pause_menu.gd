extends CanvasLayer

const SETTINGS_SCENE = preload("res://scenes/settings/settings.tscn")
const MAIN_MENU_PATH = "res://scenes/home/main_menu.tscn"

@onready var resume_btn: Button = $CenterContainer/PanelContainer/Margin/VBox/ResumeBtn
@onready var settings_btn: Button = $CenterContainer/PanelContainer/Margin/VBox/SettingsBtn
@onready var restart_btn: Button = $CenterContainer/PanelContainer/Margin/VBox/RestartBtn
@onready var quit_btn: Button = $CenterContainer/PanelContainer/Margin/VBox/QuitBtn

## If true, pausing doesn't stop the scene tree. Good for online matches.
var is_multiplayer: bool = false
var settings_instance: Node = null

func _ready() -> void:
	visible = false
	resume_btn.pressed.connect(_on_resume)
	settings_btn.pressed.connect(_on_settings)
	restart_btn.pressed.connect(_on_restart)
	quit_btn.pressed.connect(_on_quit)

	# Optional: style buttons nicely if you had a style func
	# For now, default buttons will appear.

func open() -> void:
	visible = true
	if not is_multiplayer:
		get_tree().paused = true

func close() -> void:
	visible = false
	if not is_multiplayer:
		get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		# If the settings menu is open on top of the pause menu,
		# we let the user close it naturally or we can forcefully close it.
		if settings_instance != null and is_instance_valid(settings_instance):
			settings_instance.queue_free()
		else:
			close()
		get_viewport().set_input_as_handled()

func _on_resume() -> void:
	close()

func _on_settings() -> void:
	if settings_instance == null or not is_instance_valid(settings_instance):
		settings_instance = SETTINGS_SCENE.instantiate()
		add_child(settings_instance)

func _on_restart() -> void:
	close()
	get_tree().reload_current_scene()

func _on_quit() -> void:
	close()
	SceneManager.change_scene(MAIN_MENU_PATH, SceneManager.TransitionType.FADE_BLACK, 0.4)

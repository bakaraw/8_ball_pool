extends Control
## Loading screen with animated progress bar. Loads target scene via
## ResourceLoader threaded loading.

var target_scene_path: String = ""
var transition_duration: float = 0.4

@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var spinner: Label = $CenterContainer/VBoxContainer/SpinnerLabel

var _progress: Array = []
var _loading_started := false
var _load_complete := false
var _spinner_chars := ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
var _spinner_index := 0
var _spinner_timer := 0.0
var _fake_progress := 0.0

func _ready() -> void:
	progress_bar.value = 0.0
	if target_scene_path != "":
		_start_loading()

func _start_loading() -> void:
	_loading_started = true
	status_label.text = "Loading..."
	ResourceLoader.load_threaded_request(target_scene_path)

func _process(delta: float) -> void:
	if not _loading_started:
		return

	# Animate spinner
	_spinner_timer += delta
	if _spinner_timer >= 0.08:
		_spinner_timer = 0.0
		_spinner_index = (_spinner_index + 1) % _spinner_chars.size()
		spinner.text = _spinner_chars[_spinner_index]

	# Check loading status
	var status = ResourceLoader.load_threaded_get_status(target_scene_path, _progress)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var real_progress = _progress[0] * 100.0 if _progress.size() > 0 else 0.0
		# Smooth the progress bar
		_fake_progress = lerp(_fake_progress, real_progress, delta * 8.0)
		progress_bar.value = _fake_progress
	elif status == ResourceLoader.THREAD_LOAD_LOADED and not _load_complete:
		_load_complete = true
		# Smoothly fill to 100%
		var fill_tween = create_tween()
		fill_tween.tween_property(progress_bar, "value", 100.0, 0.3).set_ease(Tween.EASE_OUT)
		await fill_tween.finished

		status_label.text = "Ready!"
		await get_tree().create_timer(0.2).timeout

		# Hand off to SceneManager (it persists as autoload, we get freed)
		var scene = ResourceLoader.load_threaded_get(target_scene_path)
		SceneManager._finish_loading_transition(scene, transition_duration)
		_loading_started = false
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		status_label.text = "Load failed! Returning to menu..."
		await get_tree().create_timer(1.5).timeout
		SceneManager.change_scene("res://scenes/home/main_menu.tscn")

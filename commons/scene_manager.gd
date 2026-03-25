extends CanvasLayer
## Global scene manager autoload. Handles all scene transitions with
## fade / dissolve effects and optional loading-screen integration.

enum TransitionType { FADE_BLACK, FADE_WHITE, DISSOLVE }

const LOADING_SCREEN_PATH := "res://scenes/loading/loading_screen.tscn"

var color_rect: ColorRect
var anim_player: AnimationPlayer


var _is_transitioning: bool = false

# ── public API ──────────────────────────────────────────────────────

## Standard scene change with a fade transition.
func change_scene(scene_path: String, transition: TransitionType = TransitionType.FADE_BLACK, duration: float = 0.5) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_set_fade_color(transition)
	await _fade_out(duration)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().create_timer(0.05).timeout  # 1 frame settle
	await _fade_in(duration)
	_is_transitioning = false

## Scene change that shows a loading screen for heavier scenes.
func change_scene_with_loading(scene_path: String, transition: TransitionType = TransitionType.FADE_BLACK, duration: float = 0.4) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_set_fade_color(transition)
	await _fade_out(duration)

	# Switch to loading screen and pass target
	var loading_scene = load(LOADING_SCREEN_PATH).instantiate()
	loading_scene.target_scene_path = scene_path
	loading_scene.transition_duration = duration
	get_tree().root.add_child(loading_scene)
	# Remove old scene
	var old_scene = get_tree().current_scene
	if old_scene:
		old_scene.queue_free()
	get_tree().current_scene = loading_scene

	await _fade_in(duration)
	_is_transitioning = false

## Quick fade out only (for splash → menu, etc.)
func fade_out_only(duration: float = 0.5, transition: TransitionType = TransitionType.FADE_BLACK) -> void:
	_set_fade_color(transition)
	await _fade_out(duration)

## Quick fade in only
func fade_in_only(duration: float = 0.5) -> void:
	await _fade_in(duration)
	_is_transitioning = false

## Called by loading screen to finish the transition safely from autoload.
func _finish_loading_transition(scene: PackedScene, duration: float) -> void:
	_is_transitioning = true
	await _fade_out(duration)
	get_tree().change_scene_to_packed(scene)
	await get_tree().create_timer(0.05).timeout
	await _fade_in(duration)
	_is_transitioning = false

# ── private helpers ─────────────────────────────────────────────────

func _ready() -> void:
	layer = 200
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_build_animations()
	# Start fully transparent
	color_rect.color.a = 0.0

func _build_ui() -> void:
	# Full-screen overlay
	var cr = ColorRect.new()
	cr.name = "ColorRect"
	cr.color = Color(0, 0, 0, 0)
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(cr)
	color_rect = cr

func _build_animations() -> void:
	var ap = AnimationPlayer.new()
	ap.name = "AnimationPlayer"
	add_child(ap)
	anim_player = ap

	# -- fade_out animation: alpha 0 → 1
	var lib = AnimationLibrary.new()

	var fade_out_anim = Animation.new()
	fade_out_anim.length = 1.0
	var track_idx = fade_out_anim.add_track(Animation.TYPE_VALUE)
	fade_out_anim.track_set_path(track_idx, "ColorRect:color")
	fade_out_anim.track_insert_key(track_idx, 0.0, Color(0, 0, 0, 0))
	fade_out_anim.track_insert_key(track_idx, 1.0, Color(0, 0, 0, 1))
	fade_out_anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_CUBIC)
	lib.add_animation("fade_out", fade_out_anim)

	# -- fade_in animation: alpha 1 → 0
	var fade_in_anim = Animation.new()
	fade_in_anim.length = 1.0
	var track_idx2 = fade_in_anim.add_track(Animation.TYPE_VALUE)
	fade_in_anim.track_set_path(track_idx2, "ColorRect:color")
	fade_in_anim.track_insert_key(track_idx2, 0.0, Color(0, 0, 0, 1))
	fade_in_anim.track_insert_key(track_idx2, 1.0, Color(0, 0, 0, 0))
	fade_in_anim.track_set_interpolation_type(track_idx2, Animation.INTERPOLATION_CUBIC)
	lib.add_animation("fade_in", fade_in_anim)

	ap.add_animation_library("", lib)

func _set_fade_color(transition: TransitionType) -> void:
	match transition:
		TransitionType.FADE_BLACK:
			color_rect.color = Color(0, 0, 0, color_rect.color.a)
		TransitionType.FADE_WHITE:
			color_rect.color = Color(1, 1, 1, color_rect.color.a)
		TransitionType.DISSOLVE:
			color_rect.color = Color(0, 0, 0, color_rect.color.a)

func _fade_out(duration: float) -> void:
	# Animate alpha from current to 1
	var start_color = color_rect.color
	var end_color = Color(start_color.r, start_color.g, start_color.b, 1.0)
	var tween = create_tween()
	tween.tween_property(color_rect, "color", end_color, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

func _fade_in(duration: float) -> void:
	var start_color = color_rect.color
	var end_color = Color(start_color.r, start_color.g, start_color.b, 0.0)
	var tween = create_tween()
	tween.tween_property(color_rect, "color", end_color, duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

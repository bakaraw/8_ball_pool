extends Node2D
class_name CueBallInput
signal cue_stick_release

@onready var cue_stick_sprite: CueStick = get_parent().get_node("CueStick")
var is_dragging = false
@onready var cue_ball: CueBall = get_parent()

var initial_mouse_pos = Vector2.ZERO
var drag_distance = 0.0
var max_drag = 100.0 


func _process(_delta: float) -> void:
	if is_dragging:
		print(drag_distance)
		get_drag_distance()
	else:
		cue_ball.direction = get_mouse_direction()
		cue_stick_sprite.cue_stick_offset = 0.0
		drag_distance = 0.0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not cue_ball._is_cue_ball_moving():
			if event.pressed:
				is_dragging = true
				initial_mouse_pos = get_local_mouse_position()
			else:
				is_dragging = false  # released, this is where you'd shoot
				initial_mouse_pos = Vector2.ZERO
				cue_stick_release.emit()

func get_mouse_direction() -> Vector2:
	var local_mouse = to_local(get_global_mouse_position())
	return local_mouse.normalized()

func get_drag_distance():
	var mouse_pos = get_local_mouse_position()
	var drag_dir = (mouse_pos - initial_mouse_pos).normalized()  # direction of drag

	if drag_dir.dot(-cue_ball.direction) > 0.9:
		var raw_distance = mouse_pos.distance_to(initial_mouse_pos)
		drag_distance = clampf(raw_distance, 0.0, max_drag)
		#var percentage = (drag_distance / max_drag) * 100.0
		cue_stick_sprite.cue_stick_offset = drag_distance
	else:
		cue_stick_sprite.cue_stick_offset = 0
		drag_distance = 0

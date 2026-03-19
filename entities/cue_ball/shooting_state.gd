extends State
class_name ShootingState

var cue_stick_sprite: CueStick
var cue_ball_trajectory: CueBallTrajectory 
var initial_mouse_pos: Vector2
var drag_distance: float = 0.0
var max_drag: float = 100.0
var cue_ball: CueBall

func enter() -> void:
	cue_ball = state_machine.get_parent()
	initial_mouse_pos = cue_ball.get_local_mouse_position()
	cue_stick_sprite = cue_ball.get_node("CueStick")
	cue_ball_trajectory = cue_ball.get_node("CueBallTrajectory")

func exit() -> void:
	cue_ball_trajectory.visible = false
	cue_stick_sprite.visible = false

func update(_delta: float):
	#print(drag_distance)
	get_drag_distance()
	cue_stick_sprite.queue_redraw()
	cue_ball_trajectory.queue_redraw()
	
func handle_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed and drag_distance > 0:
				_release_ball()
				state_machine.change_state("releasestate")
			else:
				state_machine.change_state("aimingstate")

func get_mouse_direction() -> Vector2:
	return (cue_ball.get_global_mouse_position() - cue_ball.global_position).normalized()

func get_drag_distance():
	var mouse_pos = cue_ball.get_local_mouse_position()
	var drag_dir = (mouse_pos - initial_mouse_pos).normalized() 

	if drag_dir.dot(-cue_ball.direction) > 0.9:
		var raw_distance = mouse_pos.distance_to(initial_mouse_pos)
		drag_distance = clampf(raw_distance, 0.0, max_drag)
		cue_stick_sprite.cue_stick_offset = drag_distance
	else:
		cue_stick_sprite.cue_stick_offset = 0
		drag_distance = 0
		
func _release_ball():
	var impulse = cue_ball.direction * drag_distance * cue_ball.force_multi
	cue_ball.linear_velocity = impulse

extends State
class_name AimingState

var cue_ball: CueBall
var cue_stick_sprite: CueStick
var cue_ball_trajectory: CueBallTrajectory

func enter() -> void:
	cue_ball = state_machine.get_parent()
	cue_stick_sprite = cue_ball.get_node("CueStick")
	cue_ball_trajectory = cue_ball.get_node("CueBallTrajectory")
	cue_stick_sprite.visible = true
	cue_ball_trajectory.visible = true
	
func get_mouse_direction() -> Vector2:
	return (cue_ball.get_global_mouse_position() - cue_ball.global_position).normalized()	
	
func update(_delta: float):
	cue_ball.direction = get_mouse_direction()
	cue_stick_sprite.cue_stick_offset = 0.0
	cue_stick_sprite.queue_redraw()
	cue_ball_trajectory.queue_redraw()

func handle_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				state_machine.change_state("shootingstate")

	if _mouse_over_cue_ball() and Globals.current_player.ball_in_hand:
		state_machine.change_state("ballinhandstate")

func _mouse_over_cue_ball() -> bool:
	var mouse_pos = cue_ball.get_global_mouse_position()
	var circle = cue_ball.get_node("Circle")
	return mouse_pos.distance_to(cue_ball.global_position) <= Globals.BALL_RADIUS

extends State
class_name ReleaseState

var shooting_state: ShootingState
var cue_ball: CueBall

func enter():
	shooting_state = state_machine.get_node("ShootingState")
	cue_ball = state_machine.get_parent()
	_release_ball()
	Globals.current_player.ball_in_hand = false
	cue_ball.pocketed = false
	state_machine.get_parent().emit_signal("shot_taken")

func _release_ball():
	var impulse = cue_ball.direction * shooting_state.drag_distance * cue_ball.force_multi
	cue_ball.linear_velocity = impulse

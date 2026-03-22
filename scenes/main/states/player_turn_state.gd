extends State
class_name PlayerTurnState

var cue_ball
var cue_ball_sm: StateMachine 
var ball_manager: BallManager

func enter() -> void:
	var main: MainScene = state_machine.get_parent()
	var current_player: Player = main.get_current_player()
	ball_manager = main.get_node("BallManager")
	cue_ball = main.get_node("CueBall")
	cue_ball_sm = cue_ball.get_node("StateMachine")
	cue_ball.shot_taken.connect(_on_shot_taken)
	cue_ball.reset_contact()
	ball_manager.clear_first_contact()
	cue_ball_sm.change_state("aimingstate")
	#if not current_player.ball_in_hand:
		#cue_ball_sm.change_state("aimingstate")
	#else:
		#cue_ball_sm.change_state("ballinhandstate")

func exit() -> void:
	cue_ball.shot_taken.disconnect(_on_shot_taken)
	#cue_ball.first_contact.disconnect(ball_manager.set_first_contact)

func _on_shot_taken() -> void:
	var ball_eval = state_machine.states["ballevaluation"]
	ball_eval.next_state = "playdefensivecards"
	state_machine.change_state("ballevaluation")

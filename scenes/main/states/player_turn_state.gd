extends State
class_name PlayerTurnState

var cue_ball
var cue_ball_sm: StateMachine 

func enter() -> void:
	var main: MainScene = state_machine.get_parent()
	var current_player: Player = main.get_current_player()
	cue_ball = main.get_node("CueBall")
	cue_ball_sm = cue_ball.get_node("StateMachine")
	cue_ball.shot_taken.connect(_on_shot_taken)
	
	if not current_player.ball_in_hand:
		cue_ball_sm.change_state("aimingstate")
	else:
		cue_ball_sm.change_state("ballinhandstate")

func exit() -> void:
	cue_ball.shot_taken.disconnect(_on_shot_taken)

func _on_shot_taken() -> void:
	var ball_eval = state_machine.states["ballevaluation"]
	ball_eval.next_state = "playdefensivecards"
	state_machine.change_state("ballevaluation")

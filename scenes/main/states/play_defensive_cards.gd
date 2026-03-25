extends State
class_name PlayDefensiveCards

@export var cue_ball: CueBall

# for future use
# able to use defensive cards and shit
func enter() -> void:
	#print("\t\tPLAY DEFENSIVE CARD")
	_finish()

func _finish() -> void:
	var ball_eval := state_machine.states["ballevaluation"] as BallEvaluation
	ball_eval.context = BallEvaluation.EvalContext.POST_DEFENSIVE_CARDS
	state_machine.change_state("ballevaluation")

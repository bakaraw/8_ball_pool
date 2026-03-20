extends State
class_name PlayDefensiveCards

@export var cue_ball: CueBall

# for future use
# able to use defensive cards and shit

func enter() -> void:
	var ball_eval = state_machine.states["ballevaluation"]
	ball_eval.next_state = "endturn"
	state_machine.change_state("ballevaluation")

func exit() -> void:
	pass
	
func update(_delta: float):
	pass
	
func handle_input(_event: InputEvent):
	pass

func physics_update(_delta: float):
	pass

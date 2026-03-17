extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(1, 7):  # 1 to 6
		var pocket = get_node("Pocket" + str(i))
		pocket.ball_entered.connect(_on_ball_entered)
		pocket.cue_ball_entered.connect(_on_cue_ball_entered)
	#print("Player " + str(TURN + 1) + " turn")
	#var cue_ball = get_node("CueBall")
	#cue_ball.turn_complete.connect(_on_turn_complete)
	#cue_ball.turn_complete.connect($Shader/UI._on_turn_complete)

func _on_ball_entered(ball, pocket):
	ball.ball_pocketed(pocket.position)

func _on_cue_ball_entered(ball, pocket):
	ball.cue_ball_pocketed(pocket.position)

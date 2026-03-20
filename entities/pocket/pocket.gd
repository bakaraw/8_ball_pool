extends Area2D
class_name Pocket

signal cue_ball_entered(ball, pocket)
signal ball_entered(ball, pocket)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	#if not body_exited.is_connected(_on_body_exited):
		#body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CueBall:
		#print("Scratch!!!")
		cue_ball_entered.emit(body, self)
	if body is PoolBall:
		#print("Points")
		ball_entered.emit(body, self)

#
#func _on_body_exited(body: Node2D) -> void:
	#if body is CueBall:
		#print("Scratch!!! and it exited")
		

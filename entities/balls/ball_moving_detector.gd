extends Node
class_name BallMovingDetector

@onready var ball: RigidBody2D = get_parent()
var threshold = 2.0

func is_ball_moving() -> bool:
	#print(ball.name, ": ", ball.linear_velocity.length_squared())
	return ball.linear_velocity.length_squared() > threshold

extends Node2D
class_name BallSpawner

const ball = preload("res://entities/balls/ball.tscn")
var ball_radius

func _ready() -> void:
	var temp_ball = ball.instantiate()
	ball_radius = temp_ball.get_node("Circle").radius
	temp_ball.queue_free()
	_spawn_balls()

func _spawn_balls():
	var first_ball_pos = Vector2.ZERO
	var columns = 5
	var corner_colors = [Color.GOLD, Color.DARK_RED]
	corner_colors.shuffle()
	var color_distribution = _get_ball_distribution()
	var ball_color = Color.GOLD
	
	for i in range(columns):
		var horizontal_position = (ball_radius * (i + 1))
		for j in range(i+1):
			var new_ball = ball.instantiate()
			
			new_ball.position.x = horizontal_position
			new_ball.position.y = first_ball_pos.y
			
			# Assigns color for the balls
			# black ball
			if i == 2 and j == 1:
				new_ball.get_node("Circle").color = Color.BLACK
			# corner balls color
			elif i == 4 and j == 0:
				new_ball.get_node("Circle").color = corner_colors[0]  # random
			elif i == 4 and j == 4:
				new_ball.get_node("Circle").color = corner_colors[1]  # the other one
			# the rest of the balls (randomized)
			else:
				if color_distribution.size() > 0:
					var index = randi() % color_distribution.size()
					ball_color = color_distribution.pop_at(index)  
				new_ball.get_node("Circle").color = ball_color
				
			new_ball.get_node("Circle").shadow_color = Color(0, 0, 0, 0.05)
			new_ball.get_node("Circle").drop_shadow_on = true
			add_child(new_ball)
			
func _get_ball_distribution():
	var ball_distribution = []
	for i in range(6):
		ball_distribution.append(Color.GOLD)
	for i in range(6):
		ball_distribution.append(Color.DARK_RED)
	return ball_distribution

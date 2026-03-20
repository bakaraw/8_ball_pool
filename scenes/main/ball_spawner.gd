extends Node2D
class_name BallManager

const BALL_SCENE = preload("res://entities/balls/ball.tscn")
var ball_radius

func _ready() -> void:
	var temp_ball = BALL_SCENE.instantiate()
	ball_radius = temp_ball.get_node("Circle").radius
	temp_ball.queue_free()
	_spawn_balls()

func _spawn_balls():
	if not Globals.DEBUG:
		rack_balls()
	else:
		spawn_8_ball_debug()

			
func _get_ball_distribution():
	var ball_distribution = []
	for i in range(6):
		ball_distribution.append(Color.GOLD)
	for i in range(6):
		ball_distribution.append(Color.DARK_RED)
	return ball_distribution
	
func get_balls() -> Array:
	return get_children()

func assign_balls_to_player(player: Player) -> void:
	for ball in get_balls():
		if ball.ball_type == player.ball_type:
			player.balls_to_pocket.append(ball)

func on_ball_pocketed(ball: PoolBall, player: Player) -> void:
	if ball.ball_type == player.ball_type:
		player.balls_pocketed.append(ball)

func is_eight_ball_pocketed() -> bool:
	for ball in get_balls():
		if ball.ball_type == Globals.BallType.EIGHT_BALL:
			return false
	return true

func spawn_8_ball_debug():
	var new_ball: PoolBall = BALL_SCENE.instantiate()
	new_ball.get_node("Circle").color = Color.BLACK
	new_ball.ball_type = Globals.BallType.EIGHT_BALL
	add_child(new_ball)
	new_ball.global_position = Vector2(97.0, 97.0)  # ← after add_child
	
func rack_balls():
	var first_ball_pos = Vector2.ZERO
	var columns = 5
	var corner_colors = [Color.GOLD, Color.DARK_RED]
	corner_colors.shuffle()
	var color_distribution = _get_ball_distribution()
	
	var ball_color = Color.GOLD
	var ball_type = Globals.BallType.SOLIDS
	
	for i in range(columns):
		var horizontal_position = (ball_radius * (i + 1))
		for j in range(i+1):
			var new_ball: PoolBall = BALL_SCENE.instantiate()
			
			new_ball.position.x = horizontal_position
			new_ball.position.y = first_ball_pos.y
			
			# Assigns color for the balls
			# black ball
			if i == 2 and j == 1:
				new_ball.get_node("Circle").color = Color.BLACK
				new_ball.ball_type = Globals.BallType.EIGHT_BALL
			# corner balls color
			elif i == 4 and j == 0:
				new_ball.get_node("Circle").color = corner_colors[0]  # random
				new_ball.ball_type = Globals.BallType.SOLIDS
			elif i == 4 and j == 4:
				new_ball.get_node("Circle").color = corner_colors[1]  # the other one
				new_ball.ball_type = Globals.BallType.STRIPES
			# the rest of the balls (randomized)
			else:
				if color_distribution.size() > 0:
					var index = randi() % color_distribution.size()
					ball_color = color_distribution.pop_at(index)  
					if ball_color == Color.DARK_RED:
						ball_type = Globals.BallType.STRIPES
					else:
						ball_type = Globals.BallType.SOLIDS
				new_ball.get_node("Circle").color = ball_color
				new_ball.ball_type = ball_type
				
			new_ball.get_node("Circle").shadow_color = Color(0, 0, 0, 0.05)
			new_ball.get_node("Circle").drop_shadow_on = true
			add_child(new_ball)

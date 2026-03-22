extends Node2D
class_name BallManager

const BALL_SCENE = preload("res://entities/balls/ball.tscn")
@export var pool_table: PoolTable

var first_contact_ball: PoolBall = null

var ball_pocketed_this_turn : Array[PoolBall] = []

func _ready() -> void:
	_connect_pockets()
	_spawn_balls()

func _connect_pockets():
	var pockets = pool_table.get_pockets()
	for pocket : Pocket in pockets:
		pocket.ball_entered.connect(_on_ball_entered)
		pocket.cue_ball_entered.connect(_on_cue_ball_entered)
	
func _on_ball_entered(ball, pocket):
	ball.ball_pocketed(pocket)
	ball.is_ball_pocketed = true
	ball_pocketed_this_turn.append(ball)

func _on_cue_ball_entered(ball, pocket):
	ball.cue_ball_pocketed(pocket)
	
func _spawn_balls():
	if not Globals.DEBUG:
		rack_balls()
	else:
		spawn_ball_debug()

func _get_ball_distribution():
	var ball_distribution = []
	for i in range(6):
		ball_distribution.append(Color.GOLD)
	for i in range(6):
		ball_distribution.append(Color.DARK_RED)
	return ball_distribution

func get_balls() -> Array:
	var not_pocketed_balls: Array = []
	for ball in get_children():
		if not ball.is_ball_pocketed:
			not_pocketed_balls.append(ball)
	return not_pocketed_balls

func assign_balls_to_player(player: Player) -> void:
	for ball in get_balls():
		if ball.ball_type == player.ball_type:
			player.balls_to_pocket.append(ball)

#func on_ball_pocketed(ball: PoolBall, player: Player) -> void:
	#ball.is_ball_pocketed = true
	#if ball.ball_type == player.ball_type:
		#player.balls_pocketed.append(ball)

func is_eight_ball_pocketed() -> bool:
	for ball in get_ball_pocketed_this_turn():
		if ball.ball_type == Globals.BallType.EIGHT_BALL:
			return true
	return false

func spawn_ball_debug():
	#var eight_ball: PoolBall = BALL_SCENE.instantiate()
	#eight_ball.get_node("Circle").color = Color.BLACK
	#eight_ball.ball_type = Globals.BallType.EIGHT_BALL
	#add_child(eight_ball)
	#eight_ball.global_position = Vector2(97.0, 97.0)  # ← after add_child
	var eight_ball = create_ball(Color.BLACK, Globals.BallType.EIGHT_BALL, Vector2( 97, 97))
	var stripe = create_ball(Color.DARK_RED, Globals.BallType.STRIPES, Vector2(97, 540))
	var solid = create_ball(Color.GOLD, Globals.BallType.SOLIDS, Vector2(540,540))
	var solid2 = create_ball(Color.GOLD, Globals.BallType.SOLIDS, Vector2(540,97))
	var strip2 = create_ball(Color.DARK_RED, Globals.BallType.STRIPES, Vector2(1030, 540))

func create_ball(color: Color, ball_type: Globals.BallType, pos: Vector2):
	var new_ball: PoolBall = BALL_SCENE.instantiate()
	new_ball.get_node("Circle").color = color
	new_ball.ball_type = ball_type
	add_child(new_ball)
	new_ball.global_position = pos
	return new_ball

func rack_balls():
	var first_ball_pos = Vector2.ZERO
	var columns = 5
	var corner_colors = [Color.GOLD, Color.DARK_RED]
	corner_colors.shuffle()
	var color_distribution = _get_ball_distribution()
	
	var ball_color = Color.GOLD
	var ball_type = Globals.BallType.SOLIDS
	
	for i in range(columns):
		var horizontal_position = (Globals.BALL_RADIUS * (i + 1))
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

func get_ball_pocketed_this_turn() -> Array[PoolBall]:
	return ball_pocketed_this_turn

func clear_ball_pocketed_this_turn():
	ball_pocketed_this_turn.clear()
	
func add_pocketed_to_player(player: Player, pocketed_balls: Array) -> void:
	for ball in pocketed_balls:
		if not player.balls_pocketed.has(ball):  # avoid duplicates
			player.balls_pocketed.append(ball)
				#print("\t[%s] pocketed: %s (%s)" % [
					#player.player_name
				#])

func set_first_contact(ball: PoolBall) -> void:
	print("set_first_contact called with: ", ball.get_ball_type_name())
	if first_contact_ball == null:  # only set once per turn
		first_contact_ball = ball

func get_first_contact_ball() -> PoolBall:
	return first_contact_ball

func clear_first_contact() -> void:
	first_contact_ball = null

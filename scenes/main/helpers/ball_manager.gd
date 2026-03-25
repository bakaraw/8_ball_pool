extends Node2D
class_name BallManager

## Owns ball spawning, tracking, and pocketing.
## Does NOT know about players or game rules — that's BallEvaluation's job.

const BALL_SCENE = preload("res://entities/balls/ball.tscn")

@export var pool_table: PoolTable

var _first_contact_ball: PoolBall = null
var _ball_pocketed_this_turn: Array[PoolBall] = []

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

func _ready() -> void:
	_connect_pockets()
	_spawn_balls()

func _connect_pockets() -> void:
	for pocket: Pocket in pool_table.get_pockets():
		pocket.ball_entered.connect(_on_ball_entered)
		pocket.cue_ball_entered.connect(_on_cue_ball_entered)

func _spawn_balls() -> void:
	if Globals.DEBUG:
		_spawn_debug()
	else:
		_rack_balls()

# ---------------------------------------------------------------------------
# Pocket callbacks
# ---------------------------------------------------------------------------

func _on_ball_entered(ball: PoolBall, pocket: Pocket) -> void:
	ball.ball_pocketed(pocket)
	_ball_pocketed_this_turn.append(ball)

func _on_cue_ball_entered(ball: CueBall, pocket: Pocket) -> void:
	ball.cue_ball_pocketed(pocket)

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------

func get_balls() -> Array:
	return get_children().filter(func(b): return b is PoolBall and not b.is_ball_pocketed)

func get_ball_pocketed_this_turn() -> Array[PoolBall]:
	return _ball_pocketed_this_turn

func is_eight_ball_pocketed() -> bool:
	return _ball_pocketed_this_turn.any(func(b: PoolBall): 
		return b.ball_type == Globals.BallType.EIGHT_BALL)

func get_first_contact_ball() -> PoolBall:
	return _first_contact_ball

# ---------------------------------------------------------------------------
# Mutations
# ---------------------------------------------------------------------------

func set_first_contact(ball: PoolBall) -> void:
	if _first_contact_ball == null:
		_first_contact_ball = ball
		#print("[BallManager] First contact: ", ball.get_ball_type_name())

func clear_first_contact() -> void:
	_first_contact_ball = null

func clear_ball_pocketed_this_turn() -> void:
	_ball_pocketed_this_turn.clear()

func assign_balls_to_player(player: Player) -> void:
	for ball in get_balls():
		if ball.ball_type == player.ball_type:
			if not player.balls_to_pocket.has(ball):
				player.balls_to_pocket.append(ball)

func add_pocketed_to_player(player: Player, pocketed_balls: Array) -> void:
	for ball in pocketed_balls:
		if not player.balls_pocketed.has(ball):
			player.balls_pocketed.append(ball)

# ---------------------------------------------------------------------------
# Ball spawning
# ---------------------------------------------------------------------------

func create_ball(ball_type: Globals.BallType, pos: Vector2) -> PoolBall:
	var ball: PoolBall = BALL_SCENE.instantiate()
	ball.ball_type = ball_type
	add_child(ball)
	ball.global_position = pos
	return ball

func _spawn_debug() -> void:
	create_ball(Globals.BallType.EIGHT_BALL, Vector2(97,  97))
	create_ball(Globals.BallType.STRIPES,    Vector2(97,  540))
	create_ball(Globals.BallType.SOLIDS,     Vector2(540, 540))
	create_ball(Globals.BallType.SOLIDS,     Vector2(540, 97))
	create_ball(Globals.BallType.STRIPES,    Vector2(1030,540))

func _rack_balls() -> void:
	var columns := 5
	var type_pool := _build_type_distribution()
	var corner_types := [Globals.BallType.SOLIDS, Globals.BallType.STRIPES]
	corner_types.shuffle()

	for col in range(columns):
		var x := Globals.BALL_RADIUS * (col + 1)
		for row in range(col + 1):
			var ball: PoolBall = BALL_SCENE.instantiate()
			ball.position.x = x
			ball.position.y = 0.0

			if col == 2 and row == 1:
				ball.ball_type = Globals.BallType.EIGHT_BALL
			elif col == 4 and row == 0:
				ball.ball_type = corner_types[0]
			elif col == 4 and row == 4:
				ball.ball_type = corner_types[1]
			else:
				var idx := randi() % type_pool.size()
				ball.ball_type = type_pool.pop_at(idx)

			var circle = ball.get_node("Circle")
			circle.drop_shadow_on = true
			circle.shadow_color = Color(0, 0, 0, 0.05)
			add_child(ball)

func _build_type_distribution() -> Array:
	var pool := []
	for i in range(6):
		pool.append(Globals.BallType.SOLIDS)
	for i in range(6):
		pool.append(Globals.BallType.STRIPES)
	return pool

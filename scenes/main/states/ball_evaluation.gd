extends State
class_name BallEvaluation

@export var ball_manager: BallManager
@export var cue_ball: CueBall
var next_state: String = "playdefensivecards"
var balls: Array

func enter() -> void:
	balls = ball_manager.get_balls()

func exit() -> void:
	pass
	
func update(_delta: float):
	pass
	
func handle_input(_event: InputEvent):
	pass

func physics_update(_delta: float):
	if all_balls_stopped():
		evaluate()

func evaluate():
	var main: MainScene = state_machine.get_parent()
	var current_player = main.get_current_player()
	# 1. check if 8-ball was pocketed
	if ball_manager.is_eight_ball_pocketed():
		if _is_legal_eight_ball_pocket(current_player):
			main.end_game(current_player)           # win
		else:
			main.end_game(main.get_opponent(current_player))  # loss
		state_machine.change_state("gameover")
		return
	
	# 2. check if cue ball was pocketed (scratch)
	if cue_ball._is_cue_ball_pocketed():
		print("\t\tFOUL")
		main.apply_foul(Globals.FoulType.SCRATCH, current_player)
		print("\t\tNEXT STATE: " + next_state)
		state_machine.change_state(next_state)
		return
		
	# 3. check if current player pocketed their own balls
	
	# 4. check if current player pocketed opponent's balls (foul)
	
	# 5. no balls pocketed — normal end of turn
	
	state_machine.change_state(next_state)
	print("ALL BALLS STOPPED")
	
func all_balls_stopped() -> bool:
	if balls.is_empty() or not cue_ball:
		return false
	var any_moving = balls.any(func(ball):
		if ball:
			return ball.get_node("BallMovingDetector").is_ball_moving()
		)
	var cue_ball_moving = cue_ball.get_node("BallMovingDetector").is_ball_moving()
	
	return not any_moving and not cue_ball_moving
	
func _is_legal_eight_ball_pocket(player: Player) -> bool:
	return player.all_balls_cleared()

extends State
class_name PlayerTurnState

var _cue_ball
var _cue_ball_sm: StateMachine 
var _ball_manager: BallManager
var _balls
var shot_taken = false

func enter() -> void:
	var main: MainScene = state_machine.get_parent()
	var current_player: Player = main.turn_manager.get_current_player()
	_ball_manager = main.ball_manager
	_cue_ball = main.cue_ball
	_cue_ball_sm = _cue_ball.get_node("StateMachine")
	_cue_ball.shot_taken.connect(_on_shot_taken)
	_cue_ball.reset_contact()
	_ball_manager.clear_first_contact()
	_balls = _ball_manager.get_balls()
	_cue_ball_sm.change_state("aimingstate")
	print("[PLAYERS:]")
	for player in main.turn_manager.players:
		print("\t - " + player.player_name + " - remaining: " + str(player.balls_remaining()))

func exit() -> void:
	shot_taken = false
	_cue_ball.shot_taken.disconnect(_on_shot_taken)
	#cue_ball.first_contact.disconnect(ball_manager.set_first_contact)

func _on_shot_taken() -> void:
	#var ball_eval = state_machine.states["ballevaluation"]
	var ball_eval := state_machine.states["ballevaluation"] as BallEvaluation
	ball_eval.next_state = "playdefensivecards"
	ball_eval.context = BallEvaluation.EvalContext.POST_SHOT
	shot_taken = true
	#state_machine.change_state("ballevaluation")
	
func physics_update(_delta: float):
	if shot_taken:
		if all_balls_stopped():
			state_machine.change_state("ballevaluation")

func all_balls_stopped() -> bool:
	if _balls.is_empty() or not _cue_ball:
		return false
	var any_moving = _balls.any(func(ball):
		if ball:
			return ball.get_node("BallMovingDetector").is_ball_moving()
		)
	var cue_ball_moving = _cue_ball.get_node("BallMovingDetector").is_ball_moving()
	
	return not any_moving and not cue_ball_moving

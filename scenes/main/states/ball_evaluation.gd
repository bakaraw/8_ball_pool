extends State
class_name BallEvaluation

@export var ball_manager: BallManager
@export var cue_ball: CueBall
var next_state: String = "playdefensivecards"
var balls: Array

func enter() -> void:
	balls = ball_manager.get_balls()

func exit() -> void:
	if Globals.breaking_shot:
		Globals.breaking_shot = false
	ball_manager.clear_first_contact()
	ball_manager.clear_ball_pocketed_this_turn()
	
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
			main.end_game(main.get_opposing_player())  # loss
		state_machine.change_state("gameover")
		return
	
	# 2. check if cue ball was pocketed (scratch)
	if cue_ball._is_cue_ball_pocketed():
		print("\t\tFOUL")
		main.apply_foul(Globals.FoulType.SCRATCH, current_player)
		main.request_switch_turn()
		print("\t\tNEXT STATE: " + next_state)
		state_machine.change_state(next_state)
		return
		
	# 3. check first contact foul
	if not Globals.breaking_shot and not _is_valid_first_contact(current_player):
		main.apply_foul(Globals.FoulType.WRONG_BALL, current_player)
		main.request_switch_turn()
		state_machine.change_state(next_state)
		return
		
	# 4. check if current player pocketed their own balls
	var ball_pocketed_this_turn = ball_manager.get_ball_pocketed_this_turn()
	
	# check if there is no ball pocketed
	if ball_pocketed_this_turn.is_empty():
		#print("Should switch: " + str(main.should_switch_turn) + " ; Next State: " + next_state)
		main.request_switch_turn()
		state_machine.change_state(next_state)
		return
	
	# assigns ball type to a player
	if current_player.ball_type == Globals.BallType.UNASSIGNED and not Globals.breaking_shot:
		_assign_ball_types(current_player, ball_pocketed_this_turn[0])
	
	# 5. check if current player pocketed opponent's balls (foul)
	if _pocketed_wrong_balls(current_player, ball_pocketed_this_turn) and not Globals.breaking_shot:
		main.apply_foul(Globals.FoulType.WRONG_BALL, current_player)
		ball_manager.add_pocketed_to_player(main.get_opposing_player(), ball_pocketed_this_turn)
		main.request_switch_turn()
		state_machine.change_state(next_state)
		return
		
	# 6. correct balls pocketed — player shoots again
	if not Globals.breaking_shot:
		ball_manager.add_pocketed_to_player(current_player, ball_pocketed_this_turn)
		main.should_switch_turn = false
		# if player pocketed its own ball then it skips PlayDefensiveCards state
		next_state = "endturn"
		#print("Should switch: " + str(main.should_switch_turn) + " ; Next State: " + next_state)
	else:
		next_state = "endturn"
	state_machine.change_state(next_state)

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
	print("\t\t"+ player.player_name.to_upper() + " BALLS REMAINING: " + str(player.balls_remaining()))
	 # pocketing 8-ball on break is a special case
	#if Globals.breaking_shot:
		#return false  # re-rack or re-spot depending on your rules
	return player.all_balls_cleared() and not player.ball_type == Globals.BallType.UNASSIGNED

func _assign_ball_types(player: Player, first_ball: PoolBall) -> void:
	# only assign if the first ball is a valid type=
	if first_ball.ball_type == Globals.BallType.UNASSIGNED or \
	first_ball.ball_type == Globals.BallType.EIGHT_BALL:
		return  # can't assign based on this ball
	
	var main: MainScene = state_machine.get_parent()
	var opponent = main.get_opposing_player()
	player.ball_type = first_ball.ball_type
	opponent.ball_type = Globals.BallType.STRIPES \
	if first_ball.ball_type == Globals.BallType.SOLIDS \
		else Globals.BallType.SOLIDS
	ball_manager.assign_balls_to_player(player)
	ball_manager.assign_balls_to_player(opponent)

func _pocketed_wrong_balls(player: Player, pocketed: Array) -> bool:
	return pocketed.any(func(ball):
		return ball.ball_type != player.ball_type \
		and ball.ball_type != Globals.BallType.EIGHT_BALL
		)

func _is_valid_first_contact(player: Player) -> bool:
	if Globals.breaking_shot:
		return true  # no first contact rule on break
	if player.ball_type == Globals.BallType.UNASSIGNED:
		return true  # not assigned yet, any ball is fine
	var first_contact = ball_manager.get_first_contact_ball()
	# cue ball missed everything — foul
	if first_contact == null:
		return false
	print("\t\t_is_valid_first_contact? " + str(first_contact.ball_type == player.ball_type))
	return first_contact.ball_type == player.ball_type
	#return ball_manager.get_first_contact_ball().ball_type == player.ball_type

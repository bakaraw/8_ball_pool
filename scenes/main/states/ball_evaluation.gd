extends State
class_name BallEvaluation

enum EvalContext { POST_SHOT, POST_DEFENSIVE_CARDS }
var context: EvalContext = EvalContext.POST_SHOT

var _ball_manager: BallManager
var _cue_ball: CueBall
var next_state: String = "playdefensivecards"
var balls: Array
var main: MainScene

var _current_player: Player

const RULES: Array = [
	"_rule_eight_ball_pocketed",
	"_rule_scratch",
	"_rule_no_balls_hit",
	"_rule_wrong_first_contact",
	"_rule_no_balls_pocketed",
	"_rule_wrong_balls_pocketed",
	"_rule_correct_balls_pocketed",
]

func enter() -> void:
	main = _get_main()
	_ball_manager = main.ball_manager
	_cue_ball = main.cue_ball
	_current_player = main.turn_manager.get_current_player()
	balls = _ball_manager.get_balls()

	if context == EvalContext.POST_SHOT:
		_evaluate_post_shot()
	else:
		_evaluate_post_defensive_card()

func exit() -> void:
	if Globals.breaking_shot:
		Globals.breaking_shot = false
	_ball_manager.clear_first_contact()
	_ball_manager.clear_ball_pocketed_this_turn()

func _evaluate_post_shot():
	for rule in RULES:
		if call(rule):
			return

func _evaluate_post_defensive_card():
	_go_to_end_turn()

func _rule_eight_ball_pocketed():
	if not _ball_manager.is_eight_ball_pocketed():
		return false

	if _is_legal_eight_ball_pocket(_current_player):
		main.end_game(_current_player)
	else:
		main.end_game(main.turn_manager.get_opposing_player())

	state_machine.change_state("gameover")
	return true

func _rule_scratch():
	if not _cue_ball._is_cue_ball_pocketed():
		return false
	print("\t\tFOUL: SCRATCH")
	main.foul_handler.apply(Globals.FoulType.SCRATCH, _current_player)
	main.turn_manager.request_switch_turn()
	_go_to_card_phase()
	return true

func _rule_no_balls_hit():
	var first_contact_ball = _ball_manager.get_first_contact_ball()
	if first_contact_ball:
		return false
	
	main.foul_handler.apply(Globals.FoulType.NO_CANTACT, _current_player)
	main.turn_manager.request_switch_turn()
	_go_to_card_phase()
	return true

func _rule_wrong_first_contact():
	if Globals.breaking_shot:
		return false
	if _is_valid_first_contact(_current_player):
		return false
	main.foul_handler.apply(Globals.FoulType.WRONG_BALL, _current_player)
	main.turn_manager.request_switch_turn()
	_go_to_card_phase()
	return true

func _rule_no_balls_pocketed():
	var ball_pocketed_this_turn = _ball_manager.get_ball_pocketed_this_turn()
	if not ball_pocketed_this_turn.is_empty():
		return false
	_get_main().turn_manager.request_switch_turn()
	_go_to_card_phase()
	return true

func _rule_wrong_balls_pocketed():
	if Globals.breaking_shot:
		return false
	
	var pocketed := _ball_manager.get_ball_pocketed_this_turn()
	
	# can't determine wrong balls if player has no type yet
	if not _current_player.is_assigned():
		return false
	
	if not _pocketed_wrong_balls(_current_player, pocketed):
		return false
	
	print("\t\t\tWRONG BALLS POCKETED SHEESH")
	# Only enemy balls pocketed — foul
	var opponent := _get_main().turn_manager.get_opposing_player()
	
	_get_main().foul_handler.apply(Globals.FoulType.WRONG_BALL, _current_player)
	_ball_manager.add_pocketed_to_player(opponent, pocketed)  # all go to opponent
	_get_main().turn_manager.request_switch_turn()
	_go_to_card_phase()
	return true

func _rule_correct_balls_pocketed():
	var pocketed := _ball_manager.get_ball_pocketed_this_turn()
	var opponent := _get_main().turn_manager.get_opposing_player()
		
	if not Globals.breaking_shot:
		# if player is not currently assigned to a ball
		if not _current_player.is_assigned():
			_assign_ball_types(_current_player, pocketed[0])
			
		var my_balls := pocketed.filter(func(b: PoolBall):
			return b.ball_type == _current_player.ball_type)
		var their_balls := pocketed.filter(func(b: PoolBall):
			return b.ball_type == opponent.ball_type)
			
		_ball_manager.add_pocketed_to_player(_current_player, my_balls)
		_ball_manager.add_pocketed_to_player(opponent, their_balls)
		
	# Player pocketed correctly — they shoot again, no card phase
	main.turn_manager.cancel_switch_turn()
	_go_to_end_turn()
	return true

func _is_legal_eight_ball_pocket(player: Player) -> bool:
	print("\t\t"+ player.player_name.to_upper() + " BALLS REMAINING: " + str(player.balls_remaining()))
	 # pocketing 8-ball on break is a special case
	#if Globals.breaking_shot:
		#return false  # re-rack or re-spot depending on your rules
	return player.all_balls_cleared() and not player.ball_type == Globals.BallType.UNASSIGNED

func _assign_ball_types(player: Player, first_ball: PoolBall) -> void:
	print("Assigning - Player: ", player.player_name)
	print("First ball type: ", first_ball.get_ball_type_name())
	print("Opponent: ", _get_main().turn_manager.get_opposing_player().player_name)
	# only assign if the first ball is a valid type=
	if first_ball.ball_type == Globals.BallType.UNASSIGNED or \
	first_ball.ball_type == Globals.BallType.EIGHT_BALL:
		return  # can't assign based on this ball
	
	var opponent = _get_main().turn_manager.get_opposing_player()
	print("  opponent: ", opponent.player_name)
	player.ball_type = first_ball.ball_type
	opponent.ball_type = Globals.BallType.STRIPES \
	if first_ball.ball_type == Globals.BallType.SOLIDS \
		else Globals.BallType.SOLIDS
	print("  ", player.player_name, " assigned: ", player.get_ball_type_name())
	print("  ", opponent.player_name, " assigned: ", opponent.get_ball_type_name())
	_ball_manager.assign_balls_to_player(player)
	_ball_manager.assign_balls_to_player(opponent)

func _pocketed_wrong_balls(player: Player, pocketed: Array) -> bool:
	var pocketed_own := pocketed.any(func(ball: PoolBall):
		return ball.ball_type == player.ball_type)
		
	var pocketed_enemy := pocketed.any(func(ball: PoolBall):
		return ball.ball_type != player.ball_type \
			and ball.ball_type != Globals.BallType.EIGHT_BALL)
	
	# only a foul if you pocketed enemy balls WITHOUT pocketing any of your own
	return pocketed_enemy and not pocketed_own

func _is_valid_first_contact(player: Player) -> bool:
	if Globals.breaking_shot:
		return true  # no first contact rule on break
	if player.ball_type == Globals.BallType.UNASSIGNED:
		return true  # not assigned yet, any ball is fine
	var first_contact = _ball_manager.get_first_contact_ball()
	# cue ball missed everything — foul
	if first_contact == null:
		return false
	return first_contact.ball_type == player.ball_type

func _get_main() -> MainScene:
	return state_machine.get_parent() as MainScene

func _go_to_card_phase() -> void:
	state_machine.change_state("playdefensivecards")

func _go_to_end_turn() -> void:
	state_machine.change_state("endturn")

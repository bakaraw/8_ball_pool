extends Node2D
class_name MainScene

# stores player information
var players: Array[Player] = []
var current_player_index: int = 0

var winner: Player = null

var foul: Globals.FoulType = Globals.FoulType.NONE

var should_switch_turn = false

var ball_manager: BallManager
var cue_ball: CueBall

func _ready() -> void:
	ball_manager = get_node("BallManager")
	cue_ball = get_node("CueBall")
	cue_ball.first_contact.connect(ball_manager.set_first_contact)

func request_switch_turn() -> void:
	should_switch_turn = true

func switch_turn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	Globals.current_player = get_current_player()
	should_switch_turn = false

func get_current_player() -> Player:
	return players[current_player_index]
	
func end_game(winning_player: Player) -> void:
	winner = winning_player

func get_opposing_player() -> Player:
	return players[(current_player_index + 1) % players.size()]
	
func apply_foul(foul_type: Globals.FoulType, player: Player):
	player.fouls += 1
	match foul_type:
		Globals.FoulType.SCRATCH:
			print("OPPOSING PLAYER " + get_opposing_player().player_name)
			_handle_scratch()
		Globals.FoulType.WRONG_BALL:
			_handle_wrong_ball()
		#Globals.FoulType.EIGHT_BALL_EARLY:
			#_handle_eight_ball_early()

func _handle_scratch():
	print("FOUL: Scratch")
	get_opposing_player().ball_in_hand = true
	var cue_ball: CueBall = get_node("CueBall")
	var cue_ball_spawn_point: Marker2D = get_node("CueBallSpawnPosition")
	var circle = cue_ball.get_node("Circle")
	circle.radius = Globals.BALL_RADIUS
	circle.color = Color(circle.color.r, circle.color.g, circle.color.b, 1.0)
	circle.drop_shadow_on = true
	cue_ball.position = cue_ball_spawn_point.position

func _handle_wrong_ball() -> void:
	# opponent gets ball in hand
	print("FOUL: Wrong Ball")
	get_opposing_player().ball_in_hand = true

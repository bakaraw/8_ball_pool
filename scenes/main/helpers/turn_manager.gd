extends Node
class_name TurnManager
 
## Owns everything related to whose turn it is,
## turn switching, ball-in-hand state, and breaking shot.
 
signal turn_switched(new_player: Player)
 
var players: Array[Player] = []
var current_player_index: int = 0
var _switch_requested: bool = false
 
func setup(p1_name: String, p2_name: String) -> void:
	players.clear()
	players.append(Player.new(p1_name, 1))
	players.append(Player.new(p2_name, 2))
	players[0].ball_in_hand = true
	Globals.current_player = get_current_player()
 
func get_current_player() -> Player:
	return players[current_player_index]
 
func get_opposing_player() -> Player:
	return players[(current_player_index + 1) % players.size()]
 
func request_switch_turn() -> void:
	_switch_requested = true
 
func cancel_switch_turn() -> void:
	_switch_requested = false
 
func commit_turn() -> void:
	## Called by EndTurn state. Switches if requested.
	if _switch_requested:
		_do_switch()
 
func _do_switch() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	Globals.current_player = get_current_player()
	_switch_requested = false
	turn_switched.emit(get_current_player())
 
func is_switch_requested() -> bool:
	return _switch_requested

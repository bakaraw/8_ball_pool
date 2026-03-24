extends Node
class_name FoulHandler
 
## Owns foul consequences. 
## MainScene no longer needs to know HOW a foul is resolved.
 
signal foul_applied(foul_type: Globals.FoulType, player: Player)
 
@export var cue_ball: CueBall
@export var turn_manager: TurnManager
 
func apply(foul_type: Globals.FoulType, player: Player) -> void:
	player.fouls += 1
	match foul_type:
		Globals.FoulType.SCRATCH:
			_handle_scratch()
		Globals.FoulType.WRONG_BALL:
			_handle_wrong_ball()
		Globals.FoulType.NO_CANTACT:
			_handle_no_contact()
	foul_applied.emit(foul_type, player)
	print("[FOUL] %s on %s" % [Globals.FoulType.keys()[foul_type], player.player_name])
 
func _handle_scratch() -> void:
	turn_manager.get_opposing_player().ball_in_hand = true
	cue_ball.reset()
 
func _handle_wrong_ball() -> void:
	turn_manager.get_opposing_player().ball_in_hand = true
 
func _handle_no_contact() -> void:
	turn_manager.get_opposing_player().ball_in_hand = true
	cue_ball.reset()

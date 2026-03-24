extends Node
class_name Player

var player_name: String
var player_id: int
var ball_color: Color = Color.TRANSPARENT
var ball_type: Globals.BallType = Globals.BallType.UNASSIGNED
var ball_in_hand = false
var fouls: int = 0

var balls_to_pocket: Array[PoolBall] = []    # assigned at game start
var balls_pocketed: Array[PoolBall] = []     # grows as balls are pocketed

func _init(player_name: String, player_id: int) -> void:
	self.player_name = player_name
	self.player_id = player_id

func all_balls_cleared() -> bool:
	return balls_remaining() == 0

func get_ball_type_name() -> String:
	match ball_type:
		Globals.BallType.SOLIDS:
			return "Solids"
		Globals.BallType.STRIPES:
			return "Stripes"
		Globals.BallType.EIGHT_BALL:
			return "Eight Ball"
		Globals.BallType.UNASSIGNED:
			return "Unassigned"
		_:
			return "Unknown"
			
func get_ball_color_name() -> String:
	match ball_color:
		Color.GOLD:
			return "Gold"
		Color.DARK_RED:
			return "Dark Red"
		Color.BLACK:
			return "Black"
		Color.WHITE:
			return "White"
		_:
			return "Unknown"
			
func balls_remaining() -> int:
	var still_on_table := balls_to_pocket.filter(func(b: PoolBall): 
		return not b.is_ball_pocketed)
	return still_on_table.size()
	#return maxi(0, balls_to_pocket.size() - balls_pocketed.size())
	
func reset() -> void:
	ball_type = Globals.BallType.UNASSIGNED
	ball_color = Color.TRANSPARENT
	ball_in_hand = false
	fouls = 0
	balls_to_pocket.clear()
	balls_pocketed.clear()

func is_assigned() -> bool:
	return ball_type != Globals.BallType.UNASSIGNED

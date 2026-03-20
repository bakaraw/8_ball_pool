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

func balls_remaining() -> int:
	return balls_to_pocket.size() - balls_pocketed.size()

func all_balls_cleared() -> bool:
	return balls_remaining() == 0

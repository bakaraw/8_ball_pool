extends Node
class_name Player

var player_name: String
var ball_color: Color = Color.TRANSPARENT

func _init(player_name: String) -> void:
	self.player_name = player_name

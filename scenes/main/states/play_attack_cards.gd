extends State
class_name PlayAttackCards

# temporary
# to be implemented
func enter() -> void:
	var main: MainScene = state_machine.get_parent()
	var current_player = main.get_current_player()
	print("[Current player]: " + current_player.player_name + " - " + current_player.get_ball_type_name())
	state_machine.change_state("playerturnstate")

func exit() -> void:
	pass
	
func update(_delta: float):
	pass
	
func handle_input(_event: InputEvent):
	pass

func physics_update(_delta: float):
	pass

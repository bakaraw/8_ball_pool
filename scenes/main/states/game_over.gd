extends State
class_name GameOver

func enter() -> void:
	var main: MainScene = state_machine.get_parent()
	print("GAAAAAAMEEEE OVEEEEER")
	print("[WINNER]: " + main.winner.player_name.to_upper())
	pass

func exit() -> void:
	pass
	
func update(_delta: float):
	pass
	
func handle_input(_event: InputEvent):
	pass

func physics_update(_delta: float):
	pass

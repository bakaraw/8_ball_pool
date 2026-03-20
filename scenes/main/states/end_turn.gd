extends State
class_name EndTurn

func enter() -> void:
	var main: MainScene = state_machine.get_parent()
	main.switch_turn()
	state_machine.change_state("playattackcards")

func exit() -> void:
	pass
	
func update(_delta: float):
	pass
	
func handle_input(_event: InputEvent):
	pass

func physics_update(_delta: float):
	pass

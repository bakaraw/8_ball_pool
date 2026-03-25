extends State
class_name EndTurn

func enter() -> void:
	#print("\t\tEND TURN")
	_get_main().turn_manager.commit_turn()
	state_machine.change_state("playattackcards")

func _get_main() -> MainScene:
	return state_machine.get_parent() as MainScene
	
func exit() -> void:
	pass
	
func update(_delta: float):
	pass
	
func handle_input(_event: InputEvent):
	pass

func physics_update(_delta: float):
	pass

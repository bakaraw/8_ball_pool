extends State
class_name PlayAttackCards

# temporary
# to be implemented
func enter() -> void:
	var main := _get_main()
	var current_player = main.turn_manager.get_current_player()
	#for i in range(10):
		#print()
	print("[Current player]: " + current_player.player_name.to_upper() + " - " + current_player.get_ball_type_name())
	state_machine.change_state("playerturnstate")
	
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

extends Node
class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func start():
	if initial_state:
		change_state(initial_state.name.to_lower())

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

## Changes state of the StateMachine
func change_state(new_state_name: String):
	if current_state:
		current_state.exit()
	
	current_state = states.get(new_state_name.to_lower())
	
	if current_state:
		current_state.enter()
	#
	#print(
			#"["+ self.get_parent().name +
			#" Current State]: " + 
			#current_state.name.to_lower()
		#)

func _input(event: InputEvent) -> void:
	current_state.handle_input(event)

extends Node2D

const PAUSE_MENU_SCENE = preload("res://scenes/ui/pause_menu/pause_menu.tscn")
var pause_menu: CanvasLayer = null

func _ready() -> void:
	pause_menu = PAUSE_MENU_SCENE.instantiate()
	# Set this to true dynamically later if the match is online:
	pause_menu.is_multiplayer = false 
	add_child(pause_menu)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and pause_menu != null and not pause_menu.visible:
		pause_menu.open()
		get_viewport().set_input_as_handled()

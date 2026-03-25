extends Node2D
class_name MainScene

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
var winner: Player = null
@onready var turn_manager: TurnManager = $TurnManager
@onready var foul_handler: FoulHandler = $FoulHandler
@onready var ball_manager: BallManager = $BallManager
@onready var cue_ball: CueBall = $CueBall
@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
	cue_ball.first_contact.connect(ball_manager.set_first_contact)
	state_machine.start()

func end_game(winning_player: Player) -> void:
	winner = winning_player

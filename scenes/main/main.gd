extends Node2D
class_name MainScene

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

extends State
class_name PlayerInitialization

# Usefull ni cya if mag implement na tag online multiplayer
# syncing sa players and pag load sa players type shit

@export var main: MainScene

func enter() -> void:
	main.players.append(Player.new("Player 1", 1))
	main.players.append(Player.new("Player 2", 2))
	print("[PLAYERS:]")
	for player in main.players:
		print("\t - " + player.player_name)
	main.players[0].ball_in_hand = true
	Globals.current_player = main.get_current_player()
	state_machine.change_state("playattackcards")

func exit() -> void:
	pass
	
func update(_delta: float):
	pass
	
func handle_input(_event: InputEvent):
	pass

func physics_update(_delta: float):
	pass

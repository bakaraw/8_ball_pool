extends State
class_name PlayerInitialization

# Usefull ni cya if mag implement na tag online multiplayer
# syncing sa players and pag load sa players type shit

@export var main: MainScene

func enter() -> void:
	main.turn_manager.setup("Player 1", "Player 2")
	print("[PLAYERS:]")
	for player in main.turn_manager.players:
		print("\t - " + player.player_name + " - remaining: " + str(player.balls_remaining()))
	Globals.current_player = main.turn_manager.get_current_player()
	state_machine.change_state("playattackcards")

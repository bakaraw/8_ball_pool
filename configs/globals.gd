extends Node

# Constant Global Variables/Enums
enum BallType { UNASSIGNED, SOLIDS, STRIPES, EIGHT_BALL}
enum GameState { WAITING, PLAYER_TURN, BALLS_MOVING, RESOLVE, GAME_OVER }
enum FoulType { NONE, SCRATCH, WRONG_BALL, EIGHT_BALL_EARLY }

const MAX_PLAYERS := 2
const MAX_DRAG := 100.0
const BALL_POCKET_RADIUS := 20.0
const BALL_RADIUS = 17.0

const DEBUG = false

# Global Variables for easy access
var current_player: Player = null

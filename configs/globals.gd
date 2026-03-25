extends Node

# Constant Global Variables/Enums
enum BallType { UNASSIGNED, SOLIDS, STRIPES, EIGHT_BALL}
enum FoulType { NONE, SCRATCH, WRONG_BALL, EIGHT_BALL_EARLY, NO_CANTACT}

const MAX_PLAYERS := 2
const MAX_DRAG := 100.0
const BALL_POCKET_RADIUS := 20.0
const BALL_RADIUS = 17.0

# Table bounds - used for when the cue_ball is in ball_in_hand_state
const TABLE_MIN_X: float = 60.0 + BALL_RADIUS
const TABLE_MAX_X: float = 1080.0 - BALL_RADIUS
const TABLE_MIN_Y: float = 70.0 + BALL_RADIUS
const TABLE_MAX_Y: float = 580.0 - BALL_RADIUS
const TABLE_MAX_X_BREAKING_SHOT: float = 320.0 - BALL_RADIUS

const DEBUG = false

# Global Variables for easy access
var current_player: Player = null
var breaking_shot = true

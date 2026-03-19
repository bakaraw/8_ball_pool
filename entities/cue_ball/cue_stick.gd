extends Node2D
class_name CueStick

@export var cue_ball_sprite: Sprite2D
@onready var cue_ball = get_parent()
var cue_stick_offset = 0
var direction: Vector2 = Vector2.ZERO

func _ready()-> void:
	z_index = 100
	z_as_relative = false
	y_sort_enabled = false
	
func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	draw_cue_stick_placeholder(-cue_ball.direction)
	
func draw_cue_stick_placeholder(p_direction: Vector2):
	var start = p_direction * (30.0 + cue_stick_offset)
	var end = p_direction * (200.0 + cue_stick_offset)
	draw_line(start, end, Color.WHITE, 3.0)

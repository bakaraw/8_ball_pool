@tool
extends Node2D
var color: Color = Color.WHITE
@export var radius: float = Globals.BALL_RADIUS
@export var shadow_color: Color = Color(0, 0, 0, 0.5)
@export var shadow_offset: Vector2 = Vector2(4, 4)
@export var shadow_blur: float = 5.0
@export var drop_shadow_on = false
	
func _ready() -> void:
	var ball = get_parent()
	if ball is not PoolBall and ball is not CueBall:
		return
	
	match ball.ball_type:
		Globals.BallType.UNASSIGNED:
			color = Color.WHITE
		Globals.BallType.SOLIDS:
			color = Color.GOLD
		Globals.BallType.STRIPES:
			color = Color.DARK_RED
		Globals.BallType.EIGHT_BALL:
			color = Color.BLACK
		_:
			color = Color.CYAN
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	if drop_shadow_on:
		var parent_rotation = get_parent().rotation if get_parent() else 0.0
		var corrected_offset = shadow_offset.rotated(-parent_rotation)
	
		for i in range(int(shadow_blur)):
			var t = i / shadow_blur
			var c = Color(shadow_color.r, shadow_color.g, shadow_color.b, shadow_color.a * (1.0 - t))
			draw_circle(corrected_offset * (1.0 + t * 0.3), radius + i, c)
	
	draw_circle(Vector2(0, 0), radius, color)

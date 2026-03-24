extends RigidBody2D
class_name PoolBall

var ball_type: Globals.BallType = Globals.BallType.UNASSIGNED
var is_ball_pocketed = false

func _ready() -> void:
	input_pickable = true
	linear_damp = 1.0   # bleeds speed moderately fast, like felt friction
	angular_damp = 1.0  # stops spinning at the same rate
	mass = 0.3        # not too heavy, not too light
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.7  # satisfying bounce off walls
	physics_material_override.friction = 0.4 # grips the felt on landing
	z_index = 99
	z_as_relative = false 
	lock_rotation = true
	
func ball_pocketed(pocket: Pocket):
	is_ball_pocketed = true
	var circle = $Circle
	var tween = create_tween()
	tween.set_parallel(true)  # run both tweens at the same time
	tween.tween_property(self, "global_position", pocket.position, 0.3)
	tween.tween_property(circle, "radius", 13, 0.3)
	tween.tween_property(circle, "color", Color(circle.color.r, circle.color.g, circle.color.b, 0.0), 0.3)
	circle.drop_shadow_on = false
	await tween.finished
	get_node("CollisionShape2D").disabled = true
	kill_velocity()
	#queue_free()

func kill_velocity():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = true 

func get_ball_type_name() -> String:
	match ball_type:
		Globals.BallType.SOLIDS:
			return "Solids"
		Globals.BallType.STRIPES:
			return "Stripes"
		Globals.BallType.EIGHT_BALL:
			return "Eight Ball"
		Globals.BallType.UNASSIGNED:
			return "Unassigned"
		_:
			return "Unknown"
			
func get_ball_color_name() -> String:
	var circle = get_node("Circle")
	match circle.color:
		Color.GOLD:
			return "Gold"
		Color.DARK_RED:
			return "Dark Red"
		Color.BLACK:
			return "Black"
		Color.WHITE:
			return "White"
		_:
			return "Unknown"

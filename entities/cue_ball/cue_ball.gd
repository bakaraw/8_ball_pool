extends RigidBody2D
class_name CueBall
signal shot_taken

var direction: Vector2 = Vector2.ZERO
var release_force: Vector2 = Vector2.ZERO
var cue_stick_visible = true
@export var spawn_position_marker: Marker2D
@export var force_multi: float = 25.0

@onready var cue_stick_sprite: CueStick = get_node("CueStick")
@onready var cue_ball_trajectory = get_node("CueBallTrajectory")

var pocketed = false

func _ready() -> void:
	position = spawn_position_marker.position
	input_pickable = true
	linear_damp = 1.0   # bleeds speed moderately fast, like felt friction
	angular_damp = 1.0  # stops spinning at the same rate
	mass = 0.3        # not too heavy, not too light
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.7  # satisfying bounce off walls
	physics_material_override.friction = 0.4 # grips the felt on landing
	z_index = 100
	z_as_relative = false 
	lock_rotation = true
	
func cue_ball_pocketed(pocket: Pocket):
	pocketed = true
	var circle = $Circle
	var tween = create_tween()
	tween.set_parallel(true)  # run both tweens at the same time
	tween.tween_property(self, "global_position", pocket.position, 0.3)
	tween.tween_property(circle, "radius", 13, 0.3)
	tween.tween_property(circle, "color", Color(circle.color.r, circle.color.g, circle.color.b, 0.0), 0.3)
	circle.drop_shadow_on = false
	await tween.finished
	kill_velocity()

	#var sm = get_node("StateMachine")
	#sm.change_state("foulstate")
	#queue_free()

func kill_velocity():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = true 

func _is_cue_ball_pocketed() -> bool:
	return pocketed
	
func _is_cue_ball_moving() -> bool:
	var threshold = 2.0
	return linear_velocity.length_squared() > threshold

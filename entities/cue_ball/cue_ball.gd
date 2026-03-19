extends RigidBody2D
class_name CueBall

var direction: Vector2 = Vector2.ZERO
var release_force: Vector2 = Vector2.ZERO
var cue_stick_visible = true
@export var force_multi: float = 25.0

@onready var input: CueBallInput = get_node("CueBallInput")
@onready var cue_stick_sprite: CueStick = get_node("CueStick")
@onready var cue_ball_trajectory = get_node("CueBallTrajectory")

func _ready() -> void:
	input.cue_stick_release.connect(_release_ball)
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

func _physics_process(_delta: float) -> void:
	if _is_cue_ball_moving():
		cue_stick_visible = false
		cue_stick_sprite.visible = false
		cue_ball_trajectory.visible = false
	else:
		cue_stick_visible = true
		cue_stick_sprite.visible = true
		cue_ball_trajectory.visible = true

func _release_ball():
	var impulse = direction * input.drag_distance * force_multi
	linear_velocity = impulse

func _is_cue_ball_moving() -> bool:
	var threshold = 2.0
	return linear_velocity.length_squared() > threshold
	
func cue_ball_pocketed(pocket_position: Vector2):
	var circle = $Circle
	var tween = create_tween()
	tween.set_parallel(true)  # run both tweens at the same time
	tween.tween_property(self, "global_position", pocket_position, 0.3)
	tween.tween_property(circle, "radius", 13, 0.3)
	tween.tween_property(circle, "color", Color(circle.color.r, circle.color.g, circle.color.b, 0.0), 0.3)
	await tween.finished
	queue_free()

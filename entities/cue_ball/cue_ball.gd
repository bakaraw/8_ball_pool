extends RigidBody2D
class_name CueBall
signal shot_taken
signal first_contact(ball: PoolBall)

var ball_type: Globals.BallType = Globals.BallType.UNASSIGNED
var direction: Vector2 = Vector2.ZERO
var release_force: Vector2 = Vector2.ZERO
var cue_stick_visible = true
@export var spawn_position_marker: Marker2D
@export var force_multi: float = 25.0

@onready var cue_stick_sprite: CueStick = get_node("CueStick")
@onready var cue_ball_trajectory = get_node("CueBallTrajectory")

var pocketed = false
var _has_contacted: bool = false

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
	body_entered.connect(_on_body_entered)
	
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

func kill_velocity():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = true 

func _is_cue_ball_pocketed() -> bool:
	return pocketed
	
func _is_cue_ball_moving() -> bool:
	var threshold = 2.0
	return linear_velocity.length_squared() > threshold

func _on_body_entered(body: Node) -> void:
	#print("body entered: ", body.name, " is PoolBall: ", body is PoolBall)
	if not _has_contacted and body is PoolBall:
		_has_contacted = true
		first_contact.emit(body)
		#print("First contact with: ", body.ball_type)

func reset_contact() -> void:
	_has_contacted = false

func reset() -> void:
	## Called by FoulHandler after a scratch.
	pocketed = false
	freeze = false
	kill_velocity()
	global_position = spawn_position_marker.global_position
	var circle: = $Circle
	circle.radius = Globals.BALL_RADIUS
	circle.color = Color(circle.color.r, circle.color.g, circle.color.b, 1.0)
	circle.drop_shadow_on = true

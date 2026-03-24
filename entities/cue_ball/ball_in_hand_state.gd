extends State
class_name BallInHandState

var cue_ball: CueBall
var is_dragging: bool = false
var has_been_clicked: bool = false
var is_valid_placement: bool = true

func enter() -> void:
	cue_ball = state_machine.get_parent()
	cue_ball.freeze = true  # disable physics while placing
	cue_ball.get_node("CollisionShape2D").disabled = true
	cue_ball.get_node("CueBallTrajectory").visible = false
	cue_ball.get_node("CueStick").visible = false
	is_dragging = false
	has_been_clicked = false

func exit() -> void:
	cue_ball.freeze = false  # re-enable physics when done
	cue_ball.get_node("CollisionShape2D").disabled = false

func update(_delta: float):
	if is_dragging:
		var mouse_pos = cue_ball.get_global_mouse_position()
		cue_ball.global_position = Vector2(
			clampf(mouse_pos.x, Globals.TABLE_MIN_X,
			Globals.TABLE_MAX_X_BREAKING_SHOT if Globals.breaking_shot else Globals.TABLE_MAX_X),
			clampf(mouse_pos.y, Globals.TABLE_MIN_Y, Globals.TABLE_MAX_Y)
			)
		is_valid_placement = _check_valid_placement()
		has_been_clicked = true
		cue_ball.get_node("Circle").color = Color.RED if not is_valid_placement else Color.WHITE
	else:
		# not dragging + mouse outside cue ball = go to aiming
		_check_transition()

func handle_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _mouse_over_cue_ball():
				is_dragging = true
			elif not event.pressed and is_dragging:
				is_dragging = false

func _mouse_over_cue_ball() -> bool:
	var mouse_pos = cue_ball.get_global_mouse_position()
	var circle = cue_ball.get_node("Circle")
	return mouse_pos.distance_to(cue_ball.global_position) <= circle.radius

## if mouse is outside cue ball → switch to aiming
func _check_transition() -> void:
	if not _mouse_over_cue_ball():
		cue_ball.global_position = cue_ball.position
		state_machine.change_state("aimingstate")

func _check_valid_placement() -> bool:
	var space = cue_ball.get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = cue_ball.get_node("CollisionShape2D").shape
	query.transform = cue_ball.global_transform
	query.exclude = [cue_ball]  # exclude self
	var results = space.intersect_shape(query)
	return results.is_empty()  # valid if no overlaps

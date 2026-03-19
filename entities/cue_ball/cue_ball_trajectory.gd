extends Node2D
@onready var cue_ball = get_parent()
#var direction

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	_draw_trajectory()

# Called when the node enters the scene tree for the first time.
func _draw_trajectory() -> void:
	var space = get_world_2d().direct_space_state
	
	# use slingshot_force direction instead of mouse direction
	#var direction = slingshot_force.normalized()
	var direction = cue_ball.direction
	var start = global_position
	var num_bounces = 1
	var alpha = 0.5
	var excluded = [self]

	for i in range(num_bounces):
		var query = PhysicsRayQueryParameters2D.create(start, start + cue_ball.direction * 1000)
		query.exclude = excluded
		var result = space.intersect_ray(query)

		if result:
			draw_line(to_local(start), to_local(result.position), Color(1, 1, 1, alpha), 2.0)
			direction = cue_ball.direction.bounce(result.normal)
			start = result.position + direction 
			excluded = [self, result.collider]
			alpha -= 0.15
		else:
			draw_line(to_local(start), to_local(start + direction * 1000), Color(1, 1, 1, alpha), 2.0)
			break

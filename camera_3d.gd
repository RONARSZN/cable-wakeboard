extends Camera3D

var target: Node3D
var follow_distance = 10.0
var follow_height = 4.0
var look_height = 1.5
var follow_smoothing = 0.12
var movement_direction = Vector3.FORWARD
var last_target_position = Vector3.ZERO

func _ready():
	target = get_node("/root/Main/CablePath/Rider")
	if target:
		last_target_position = target.global_position

func _process(delta):
	if target:
		var target_pos = target.global_position
		var target_movement = target_pos - last_target_position

		if target_movement.length() > 0.001:
			movement_direction = target_movement.normalized()

		var desired_position = target_pos - movement_direction * follow_distance
		desired_position.y += follow_height

		global_position = global_position.lerp(desired_position, follow_smoothing)
		look_at(target_pos + Vector3.UP * look_height, Vector3.UP)
		last_target_position = target_pos
	

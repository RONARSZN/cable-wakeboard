extends PathFollow3D

var speed = 0.05

# Jump variables
var is_jumping = false
var jump_velocity = 0.0
var gravity = -20.0
var jump_force = 10.0
var vertical_offset = 0.0

# Trick variables
var swipe_start = Vector2.ZERO
var swipe_threshold = 50.0
var last_trick = ""
var last_trick_points = 0
var obstacle_cooldowns = {}
var obstacle_cooldown_time = 1.0
var kicker_boost = 3.5

# Animation variables
var is_animating = false
var rotation_speed = 0.0
var target_rotation = 0.0
var current_rotation = 0.0

# Trick definitions
var tricks = {
	"left": {"name": "Heelside 180", "points": 100},
	"right": {"name": "Toeside 180", "points": 100},
	"up": {"name": "Backroll", "points": 300},
	"down": {"name": "Front Roll", "points": 300},
	"up_left": {"name": "Heelside 360", "points": 500},
	"up_right": {"name": "Toeside 360", "points": 500},
}

func _process(delta):
	progress_ratio -= speed * delta
	if progress_ratio <= 0.0:
		progress_ratio = 1.0
	_update_obstacle_cooldowns(delta)
	
	if is_jumping:
		jump_velocity += gravity * delta
		vertical_offset += jump_velocity * delta
		
		if vertical_offset <= 0.0:
			vertical_offset = 0.0
			jump_velocity = 0.0
			is_jumping = false
			
			# Check if trick was performed
			if last_trick == "":
				# Crashed - no trick performed
				var ui = get_node("/root/Main/UI")
				ui.crash()
			else:
				last_trick = ""
				last_trick_points = 0
			
	# Trick rotation animation
	if is_animating:
		current_rotation += rotation_speed
		$MeshInstance3D.rotation_degrees.z = current_rotation
		if not is_jumping:
			# Reset rotation on landing
			$MeshInstance3D.rotation_degrees.z = 0.0
			current_rotation = 0.0
			is_animating = false
	
	$MeshInstance3D.position.y = vertical_offset
	_check_obstacle_interactions()

func jump():
	if not is_jumping:
		is_jumping = true
		jump_velocity = jump_force
		last_trick = ""
		last_trick_points = 0

func _check_obstacle_interactions():
	var obstacle_parent = get_node_or_null("/root/Main/Obstacles")
	if obstacle_parent == null:
		return

	for obstacle in obstacle_parent.get_children():
		if not obstacle is Node3D or _is_obstacle_on_cooldown(obstacle):
			continue

		var radius = float(obstacle.get_meta("interaction_radius", 3.0))
		if _horizontal_distance(global_position, obstacle.global_position) <= radius:
			_handle_obstacle(obstacle)
			obstacle_cooldowns[obstacle.get_instance_id()] = obstacle_cooldown_time
			return

func _handle_obstacle(obstacle: Node3D):
	var obstacle_kind = str(obstacle.get_meta("obstacle_kind", ""))
	if obstacle_kind == "kicker":
		_hit_kicker()
	elif obstacle_kind == "grind":
		_hit_grind_obstacle(obstacle)

func _hit_kicker():
	if not is_jumping:
		jump()
		jump_velocity += kicker_boost
	_show_obstacle_message("Kicker pop", 0)

func _hit_grind_obstacle(obstacle: Node3D):
	if is_jumping and vertical_offset <= 1.4:
		last_trick = obstacle.name + " grind"
		last_trick_points = int(obstacle.get_meta("points", 0))
		_show_obstacle_message(last_trick, last_trick_points)
	else:
		var ui = get_node_or_null("/root/Main/UI")
		if ui:
			ui.crash()

func _show_obstacle_message(message: String, points: int):
	var ui = get_node_or_null("/root/Main/UI")
	if ui:
		ui.show_obstacle(message, points)

func _update_obstacle_cooldowns(delta: float):
	var expired = []
	for obstacle_id in obstacle_cooldowns.keys():
		obstacle_cooldowns[obstacle_id] -= delta
		if obstacle_cooldowns[obstacle_id] <= 0.0:
			expired.append(obstacle_id)

	for obstacle_id in expired:
		obstacle_cooldowns.erase(obstacle_id)

func _is_obstacle_on_cooldown(obstacle: Node3D) -> bool:
	return obstacle_cooldowns.has(obstacle.get_instance_id())

func _horizontal_distance(first: Vector3, second: Vector3) -> float:
	first.y = 0.0
	second.y = 0.0
	return first.distance_to(second)

func detect_trick(swipe: Vector2):
	if not is_jumping:
		return
	
	var dx = swipe.x
	var dy = swipe.y  # Negative = up on screen
	
	var is_up = dy < -swipe_threshold
	var is_down = dy > swipe_threshold
	var is_left = dx < -swipe_threshold
	var is_right = dx > swipe_threshold
	
	if is_up and is_left:
		apply_trick("up_left")
	elif is_up and is_right:
		apply_trick("up_right")
	elif is_up:
		apply_trick("up")
	elif is_down:
		apply_trick("down")
	elif is_left:
		apply_trick("left")
	elif is_right:
		apply_trick("right")

func apply_trick(direction: String):
	if direction in tricks:
		last_trick = tricks[direction]["name"]
		last_trick_points = tricks[direction]["points"]
		print("Trick: ", last_trick, " - ", last_trick_points, " pts")
		var ui = get_node("/root/Main/UI")
		ui.show_trick(last_trick, last_trick_points)
		
		# Trigger rotation based on trick
		is_animating = true
		if direction in ["left", "up_left"]:
			rotation_speed = -5.0
		elif direction in ["right", "up_right"]:
			rotation_speed = 5.0
		elif direction == "up":
			rotation_speed = 5.0
		elif direction == "down":
			rotation_speed = -5.0

func _input(event):
	# Keyboard - PC testing
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			jump()
		elif event.keycode == KEY_LEFT:
			detect_trick(Vector2(-100, 0))
		elif event.keycode == KEY_RIGHT:
			detect_trick(Vector2(100, 0))
		elif event.keycode == KEY_UP:
			detect_trick(Vector2(0, -100))
		elif event.keycode == KEY_DOWN:
			detect_trick(Vector2(0, 100))
	
	# Touch - swipe detection
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
			jump()
		else:
			var swipe = event.position - swipe_start
			detect_trick(swipe)
				 

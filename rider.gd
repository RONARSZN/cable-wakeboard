extends PathFollow3D

const RiderFactoryScript = preload("res://rider_factory.gd")

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
var obstacle_approach_radius = 22.0
var approach_axis = 0
var max_lane_offset = 10.0
var target_lane_offset = 0.0
var current_lane_offset = 0.0
var lane_change_speed = 18.0
var is_riding_obstacle = false
var obstacle_ride_timer = 0.0
var obstacle_ride_duration = 1.1
var obstacle_ride_height = 0.0

# Animation variables
var is_animating = false
var rotation_speed = 0.0
var trick_rotation_axis = "y"
var target_rotation = 0.0
var current_rotation = 0.0
var required_hold_time = 0.65
var spin_180_hold_time = 0.38
var spin_360_hold_time = 0.85
var trick_hold_time = 0.0
var active_trick_direction = ""
var active_trick_name = ""
var active_trick_points = 0
var target_rotation_amount = 0.0
var active_spin_side = ""
var base_stance_yaw = 90.0
var stance_yaw = 90.0
var visual_root: Node3D
var grind_pose_timer = 0.0
var grind_pose_duration = 1.0

# Trick definitions
var tricks = {
	"left": {"name": "Heelside 180", "points": 100},
	"right": {"name": "Toeside 180", "points": 100},
	"up": {"name": "Backroll", "points": 300},
	"down": {"name": "Front Roll", "points": 300},
	"up_left": {"name": "Heelside 360", "points": 500},
	"up_right": {"name": "Toeside 360", "points": 500},
}

func _ready():
	visual_root = $MeshInstance3D
	RiderFactoryScript.populate(visual_root)
	_apply_ride_pose()

func _process(delta):
	progress_ratio += speed * delta
	if progress_ratio >= 1.0:
		progress_ratio = 0.0
	_update_lane_offset(delta)
	_update_obstacle_cooldowns(delta)
	
	if is_riding_obstacle:
		_update_obstacle_ride(delta)
	elif is_jumping:
		jump_velocity += gravity * delta
		vertical_offset += jump_velocity * delta
		
		if vertical_offset <= 0.0:
			vertical_offset = 0.0
			jump_velocity = 0.0
			is_jumping = false
			last_trick = ""
			last_trick_points = 0
			
	# Trick rotation animation
	if is_animating:
		trick_hold_time += delta
		var hold_target = required_hold_time
		if active_spin_side != "":
			hold_target = spin_360_hold_time
		var trick_progress = min(trick_hold_time / hold_target, 1.0)
		current_rotation = target_rotation_amount * trick_progress
		_apply_trick_rotation(current_rotation)
		if trick_progress >= 1.0:
			_finish_trick_rotation(true)
		if not is_jumping:
			# Reset rotation on landing
			_finish_trick_rotation(false)
	
	_update_pose(delta)
	visual_root.position.y = vertical_offset
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
		grind_pose_timer = grind_pose_duration
		_start_obstacle_ride(obstacle)
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

func _update_lane_offset(delta: float):
	target_lane_offset = approach_axis * max_lane_offset
	current_lane_offset = move_toward(current_lane_offset, target_lane_offset, lane_change_speed * delta)
	h_offset = current_lane_offset

func _set_approach_axis(axis: int):
	approach_axis = clamp(axis, -1, 1)

func _start_obstacle_ride(obstacle: Node3D):
	is_riding_obstacle = true
	is_jumping = false
	jump_velocity = 0.0
	obstacle_ride_timer = obstacle_ride_duration
	obstacle_ride_height = float(obstacle.get_meta("ride_height", 0.9))
	vertical_offset = obstacle_ride_height
	_apply_grind_pose()

func _update_obstacle_ride(delta: float):
	obstacle_ride_timer -= delta
	vertical_offset = obstacle_ride_height
	if obstacle_ride_timer <= 0.0:
		is_riding_obstacle = false
		vertical_offset = 0.0

func _update_pose(delta: float):
	if is_animating:
		return

	if grind_pose_timer > 0.0:
		grind_pose_timer -= delta
		if grind_pose_timer > 0.0:
			_apply_grind_pose()
			return

	if is_riding_obstacle:
		_apply_grind_pose()
	elif is_jumping:
		_apply_pop_pose()
	elif _is_approaching_obstacle():
		_apply_edge_pose()
	else:
		_apply_ride_pose()

func _apply_ride_pose():
	visual_root.rotation_degrees = Vector3(-3.0, stance_yaw, 0.0)
	_set_body_pose(-6.0, 0.0)

func _apply_edge_pose():
	visual_root.rotation_degrees = Vector3(-7.0, stance_yaw, -13.0)
	_set_body_pose(-14.0, -8.0)

func _apply_pop_pose():
	visual_root.rotation_degrees = Vector3(-10.0, stance_yaw, -12.0)
	_set_body_pose(-18.0, -15.0)

func _apply_grind_pose():
	visual_root.rotation_degrees = Vector3(-18.0, stance_yaw, -28.0)
	_set_body_pose(-36.0, -22.0)

func _set_body_pose(body_x: float, body_z: float):
	var body = visual_root.get_node_or_null("RiderBody")
	if body:
		body.rotation_degrees.x = body_x
		body.rotation_degrees.z = body_z

func _is_approaching_obstacle() -> bool:
	var obstacle_parent = get_node_or_null("/root/Main/Obstacles")
	if obstacle_parent == null:
		return false

	for obstacle in obstacle_parent.get_children():
		if obstacle is Node3D:
			if _horizontal_distance(global_position, obstacle.global_position) <= obstacle_approach_radius:
				return true
	return false

func _apply_trick_rotation(rotation_amount: float):
	if trick_rotation_axis == "y":
		visual_root.rotation_degrees.y = stance_yaw + rotation_amount
	elif trick_rotation_axis == "x":
		visual_root.rotation_degrees.x = rotation_amount

func _clear_trick_rotation():
	visual_root.rotation_degrees.y = stance_yaw
	_apply_ride_pose()

func _finish_trick_rotation(completed: bool):
	if not is_animating:
		return

	is_animating = false
	if completed:
		if active_spin_side != "":
			var degrees = 360
			if abs(current_rotation) < 300.0:
				degrees = 180
			_set_stance_yaw(degrees)
			active_trick_name = _spin_name_for_degrees(active_spin_side, degrees)
			active_trick_points = _spin_points_for_degrees(degrees)
		last_trick = active_trick_name
		last_trick_points = active_trick_points
		var ui = get_node("/root/Main/UI")
		ui.show_trick(last_trick, last_trick_points)
	else:
		_show_obstacle_message("Underrotated", 0)

	current_rotation = 0.0
	trick_hold_time = 0.0
	active_trick_direction = ""
	active_trick_name = ""
	active_trick_points = 0
	active_spin_side = ""
	_clear_trick_rotation()

func _release_trick_key(direction: String):
	if is_animating and active_trick_direction == direction:
		_finish_trick_rotation(false)

func _start_spin_key(side: String):
	if not is_jumping or is_animating:
		return

	active_spin_side = side
	active_trick_direction = side
	active_trick_name = _spin_name_for_degrees(side, 360)
	active_trick_points = 500
	trick_hold_time = 0.0
	current_rotation = 0.0
	target_rotation_amount = 360.0
	if side == "left":
		target_rotation_amount = -360.0
	trick_rotation_axis = "y"
	is_animating = true

func _finish_spin_key(side: String):
	if not is_animating or active_spin_side != side:
		return

	var finished_degrees = abs(current_rotation)
	if finished_degrees >= 300.0:
		_finish_trick_rotation(true)
	elif finished_degrees >= 140.0 and trick_hold_time >= spin_180_hold_time:
		_finish_trick_rotation(true)
	else:
		_finish_trick_rotation(false)

func _spin_name_for_degrees(side: String, degrees: int) -> String:
	if side == "left":
		return "Heelside " + str(degrees)
	return "Toeside " + str(degrees)

func _spin_points_for_degrees(degrees: int) -> int:
	if degrees >= 360:
		return 500
	return 100

func _set_stance_yaw(degrees: int):
	if degrees == 180:
		stance_yaw = wrapf(stance_yaw + 180.0, 0.0, 360.0)
	elif degrees >= 360:
		stance_yaw = base_stance_yaw

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
		active_trick_direction = direction
		active_trick_name = tricks[direction]["name"]
		active_trick_points = tricks[direction]["points"]
		trick_hold_time = 0.0
		print("Trick started: ", active_trick_name)
		is_animating = true
		if direction in ["left", "up_left"]:
			trick_rotation_axis = "y"
			target_rotation_amount = -_rotation_for_direction(direction)
		elif direction in ["right", "up_right"]:
			trick_rotation_axis = "y"
			target_rotation_amount = _rotation_for_direction(direction)
		elif direction == "up":
			trick_rotation_axis = "x"
			target_rotation_amount = 360.0
		elif direction == "down":
			trick_rotation_axis = "x"
			target_rotation_amount = -360.0

func _rotation_for_direction(direction: String) -> float:
	if direction in ["up_left", "up_right"]:
		return 360.0
	return 180.0

func _input(event):
	# Keyboard - PC testing
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_SPACE:
				jump()
			elif event.keycode == KEY_A:
				_set_approach_axis(1)
			elif event.keycode == KEY_D:
				_set_approach_axis(-1)
			elif event.keycode == KEY_LEFT:
				_start_spin_key("left")
			elif event.keycode == KEY_RIGHT:
				_start_spin_key("right")
			elif event.keycode == KEY_UP:
				apply_trick("up")
			elif event.keycode == KEY_DOWN:
				apply_trick("down")
		else:
			if event.keycode == KEY_A and approach_axis > 0:
				_set_approach_axis(0)
			elif event.keycode == KEY_D and approach_axis < 0:
				_set_approach_axis(0)
			elif event.keycode == KEY_LEFT:
				_finish_spin_key("left")
			elif event.keycode == KEY_RIGHT:
				_finish_spin_key("right")
			elif event.keycode == KEY_UP:
				_release_trick_key("up")
			elif event.keycode == KEY_DOWN:
				_release_trick_key("down")
	
	# Touch - swipe detection
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
			jump()
		else:
			var swipe = event.position - swipe_start
			detect_trick(swipe)
				 

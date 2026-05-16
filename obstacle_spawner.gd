class_name ObstacleSpawner

const ObstacleFactoryScript = preload("res://obstacle_factory.gd")

const MAX_OBSTACLES = 8
const SNAP_RADIUS = 8.0
const LAYOUT_PATH = "user://obstacle_layout.cfg"

const TOP_1 = "TOP_1"
const TOP_2 = "TOP_2"
const TOP_3 = "TOP_3"
const TOP_4 = "TOP_4"
const TOP_5 = "TOP_5"
const TOP_6 = "TOP_6"
const TOP_7 = "TOP_7"
const BOTTOM_1 = "BOTTOM_1"
const BOTTOM_2 = "BOTTOM_2"
const BOTTOM_3 = "BOTTOM_3"
const BOTTOM_4 = "BOTTOM_4"
const BOTTOM_5 = "BOTTOM_5"
const BOTTOM_6 = "BOTTOM_6"
const BOTTOM_7 = "BOTTOM_7"

const SPAWN_POINTS = {
	TOP_1: Vector3(-55, 0, -120),
	TOP_2: Vector3(-55, 0, -80),
	TOP_3: Vector3(-55, 0, -40),
	TOP_4: Vector3(-55, 0, 0),
	TOP_5: Vector3(-55, 0, 40),
	TOP_6: Vector3(-55, 0, 80),
	TOP_7: Vector3(-55, 0, 120),
	BOTTOM_1: Vector3(55, 0, -120),
	BOTTOM_2: Vector3(55, 0, -80),
	BOTTOM_3: Vector3(55, 0, -40),
	BOTTOM_4: Vector3(55, 0, 0),
	BOTTOM_5: Vector3(55, 0, 40),
	BOTTOM_6: Vector3(55, 0, 80),
	BOTTOM_7: Vector3(55, 0, 120),
}

static func place_obstacle(obstacle_type: String, spawn_point: String) -> Node3D:
	if _has_saved_layout():
		load_layout()
		return null
	if not SPAWN_POINTS.has(spawn_point):
		return null
	return add_obstacle(obstacle_type, SPAWN_POINTS[spawn_point], 0.0, false)

static func add_obstacle(
	obstacle_type: String,
	position: Vector3,
	rotation_y: float = 0.0,
	save_after: bool = true
) -> Node3D:
	var obstacles = _get_obstacles_parent()
	if obstacles == null or obstacles.get_child_count() >= MAX_OBSTACLES:
		return null

	var obstacle = ObstacleFactoryScript.create_obstacle(obstacle_type)
	if obstacle == null:
		return null

	obstacle.position = _water_position(position)
	obstacle.rotation.y = rotation_y
	obstacles.add_child(obstacle)
	if save_after:
		save_layout()
	return obstacle

static func remove_obstacle(obstacle: Node3D, save_after: bool = true):
	if obstacle == null:
		return
	var parent = obstacle.get_parent()
	if parent:
		parent.remove_child(obstacle)
	obstacle.queue_free()
	if save_after:
		save_layout()

static func clear_obstacles():
	var obstacles = _get_obstacles_parent()
	if obstacles == null:
		return
	for obstacle in obstacles.get_children():
		obstacles.remove_child(obstacle)
		obstacle.queue_free()

static func get_obstacle_count() -> int:
	var obstacles = _get_obstacles_parent()
	if obstacles == null:
		return 0
	return obstacles.get_child_count()

static func get_nearest_snap(position: Vector3) -> Vector3:
	var closest_point = position
	var closest_distance = SNAP_RADIUS
	for snap_point in SPAWN_POINTS.values():
		var distance = _horizontal_distance(position, snap_point)
		if distance <= closest_distance:
			closest_distance = distance
			closest_point = snap_point
	return _water_position(closest_point)

static func find_obstacle_near(position: Vector3) -> Node3D:
	var obstacles = _get_obstacles_parent()
	if obstacles == null:
		return null

	var closest: Node3D = null
	var closest_distance = INF
	for obstacle in obstacles.get_children():
		if not obstacle is Node3D:
			continue
		var radius = float(obstacle.get_meta("interaction_radius", 8.0))
		var distance = _horizontal_distance(position, obstacle.global_position)
		if distance <= radius and distance < closest_distance:
			closest = obstacle
			closest_distance = distance
	return closest

static func save_layout():
	var obstacles = _get_obstacles_parent()
	if obstacles == null:
		return

	var config = ConfigFile.new()
	config.set_value("layout", "count", min(obstacles.get_child_count(), MAX_OBSTACLES))
	var index = 0
	for obstacle in obstacles.get_children():
		if not obstacle is Node3D or index >= MAX_OBSTACLES:
			continue
		config.set_value("obstacle_" + str(index), "type", str(obstacle.get_meta("obstacle_type", "")))
		config.set_value("obstacle_" + str(index), "position", obstacle.position)
		config.set_value("obstacle_" + str(index), "rotation_y", obstacle.rotation.y)
		index += 1
	config.save(LAYOUT_PATH)

static func load_layout() -> bool:
	var config = ConfigFile.new()
	if config.load(LAYOUT_PATH) != OK:
		return false

	clear_obstacles()
	var count = min(int(config.get_value("layout", "count", 0)), MAX_OBSTACLES)
	for index in range(count):
		var section = "obstacle_" + str(index)
		var obstacle_type = str(config.get_value(section, "type", ""))
		var position = config.get_value(section, "position", Vector3.ZERO)
		var rotation_y = float(config.get_value(section, "rotation_y", 0.0))
		add_obstacle(obstacle_type, position, rotation_y, false)
	return true

static func _has_saved_layout() -> bool:
	return FileAccess.file_exists(LAYOUT_PATH)

static func _water_position(position: Vector3) -> Vector3:
	position.y = 0.0
	return position

static func _horizontal_distance(first: Vector3, second: Vector3) -> float:
	first.y = 0.0
	second.y = 0.0
	return first.distance_to(second)

static func _get_obstacles_parent() -> Node3D:
	var tree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	var main = tree.root.get_node_or_null("Main")
	if main == null:
		return null

	var obstacles = main.get_node_or_null("Obstacles")
	if obstacles == null:
		obstacles = Node3D.new()
		obstacles.name = "Obstacles"
		main.add_child(obstacles)
	return obstacles

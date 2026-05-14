extends Path3D

const SceneryFactoryScript = preload("res://scenery_factory.gd")

func _ready():
	var new_curve = Curve3D.new()

	# 1 Godot unit = 1 meter.
	# These 5 points create a Deca-style full-size cable layout.
	# The full lap is close to 718 meters.
	var points = [
		Vector3(0, 0, -99),     # Back tower
		Vector3(127, 0, -52),   # Right back tower
		Vector3(113, 0, 71),    # Right front tower
		Vector3(0, 0, 108),     # Front tower
		Vector3(-127, 0, -52),  # Left tower
	]

	# Add each tower point to the cable path.
	for point in points:
		new_curve.add_point(point)

	# Add the first point again at the end.
	# This closes the lap so the rider keeps looping.
	new_curve.add_point(points[0])

	# Give the finished curve to the CablePath node.
	self.curve = new_curve

	_add_scenery(points)
	_add_environment(points)
	_add_obstacles()

func _add_scenery(points: Array):
	get_parent().call_deferred("add_child", SceneryFactoryScript.create_wakepark_scene(points))

func _add_environment(points: Array):
	var environment_parent = Node3D.new()
	environment_parent.name = "CableParkMarkers"
	var course_center = _average_point(points)

	for index in range(points.size()):
		var cable_point = points[index]
		var tower = _create_tower_for_index(index)
		tower.position = _tower_base_position(cable_point, course_center)
		tower.look_at_from_position(tower.position, cable_point, Vector3.UP)
		environment_parent.add_child(tower)

		var marker = EnvironmentFactory.create_course_marker("Marker" + str(index + 1))
		marker.position = _marker_position(cable_point, course_center)
		environment_parent.add_child(marker)

	get_parent().call_deferred("add_child", environment_parent)

func _create_tower_for_index(index: int) -> Node3D:
	if index == 0:
		return EnvironmentFactory.create_engine_tower("EngineTower")
	return EnvironmentFactory.create_corner_tower("Tower" + str(index + 1))

func _tower_base_position(cable_point: Vector3, course_center: Vector3) -> Vector3:
	return cable_point + _outward_from_center(cable_point, course_center) * 16.0

func _marker_position(cable_point: Vector3, course_center: Vector3) -> Vector3:
	return cable_point + _outward_from_center(cable_point, course_center) * 4.0 + Vector3(0, 0.35, 0)

func _average_point(points: Array) -> Vector3:
	var total = Vector3.ZERO
	for point in points:
		total += point
	return total / points.size()

func _outward_from_center(point: Vector3, center: Vector3) -> Vector3:
	var outward = point - center
	outward.y = 0.0
	return outward.normalized()

func _add_obstacles():
	var obstacle_parent = Node3D.new()
	obstacle_parent.name = "Obstacles"

	_place_obstacle_on_segment(
		obstacle_parent,
		ObstacleFactory.create_kicker(),
		Vector3(127, 0, -52),
		Vector3(113, 0, 71),
		0.58,
		9.0
	)

	_place_obstacle_on_segment(
		obstacle_parent,
		ObstacleFactory.create_flat_box(),
		Vector3(113, 0, 71),
		Vector3(0, 0, 108),
		0.42,
		-10.0
	)

	_place_obstacle_on_segment(
		obstacle_parent,
		ObstacleFactory.create_pipe_rail(),
		Vector3(0, 0, 108),
		Vector3(-127, 0, -52),
		0.6,
		8.0
	)

	get_parent().call_deferred("add_child", obstacle_parent)

func _place_obstacle_on_segment(
	parent: Node3D,
	obstacle: Node3D,
	start: Vector3,
	end: Vector3,
	amount: float,
	lateral_offset: float
):
	obstacle.position = _point_between(start, end, amount) + _side_offset(start, end, lateral_offset)
	obstacle.rotation.y = _path_angle(start, end)
	parent.add_child(obstacle)

func _point_between(start: Vector3, end: Vector3, amount: float) -> Vector3:
	return start.lerp(end, amount)

func _path_angle(start: Vector3, end: Vector3) -> float:
	var direction = end - start
	return atan2(direction.x, direction.z)

func _side_offset(start: Vector3, end: Vector3, amount: float) -> Vector3:
	var direction = (end - start).normalized()
	return Vector3(direction.z, 0.0, -direction.x) * amount

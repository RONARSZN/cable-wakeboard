extends Path3D

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

	_add_obstacles()

func _add_obstacles():
	# Basic ramp on the right straight.
	# Place it directly on the same segment the rider follows.
	var ramp = MeshInstance3D.new()
	var ramp_mesh = PrismMesh.new()
	ramp_mesh.size = Vector3(8, 1.5, 14)
	ramp.mesh = ramp_mesh
	ramp.position = _point_between(Vector3(127, 0, -52), Vector3(113, 0, 71), 0.58) + Vector3(0, 0.75, 0)
	ramp.rotation.y = _path_angle(Vector3(127, 0, -52), Vector3(113, 0, 71))
	get_parent().call_deferred("add_child", ramp)

	# Basic rail on the left straight.
	# Keep it centered on the rider path instead of guessing world coordinates.
	var rail = MeshInstance3D.new()
	var rail_mesh = BoxMesh.new()
	rail_mesh.size = Vector3(1, 0.5, 18)
	rail.mesh = rail_mesh
	rail.position = _point_between(Vector3(0, 0, 108), Vector3(-127, 0, -52), 0.6) + Vector3(0, 0.5, 0)
	rail.rotation.y = _path_angle(Vector3(0, 0, 108), Vector3(-127, 0, -52))
	get_parent().call_deferred("add_child", rail)

func _point_between(start: Vector3, end: Vector3, amount: float) -> Vector3:
	return start.lerp(end, amount)

func _path_angle(start: Vector3, end: Vector3) -> float:
	var direction = end - start
	return atan2(direction.x, direction.z)

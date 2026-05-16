class_name ObstacleFactory

const WATERLINE_Y = 0.0

const AVAILABLE_OBSTACLES = [
	{"type": "table_long", "label": "Table Long"},
	{"type": "kicker", "label": "Kicker"},
	{"type": "flat_box", "label": "Flat Box"},
	{"type": "pipe_rail", "label": "Pipe Rail"},
]

static func get_available_obstacles() -> Array:
	return AVAILABLE_OBSTACLES.duplicate(true)

static func create_obstacle(obstacle_type: String) -> Node3D:
	match obstacle_type:
		"kicker":
			return create_kicker()
		"flat_box":
			return create_flat_box()
		"pipe_rail":
			return create_pipe_rail()
		"table_long":
			return create_table_long()
	return null

static func create_kicker() -> Node3D:
	var obstacle = _create_obstacle_root("Kicker", "kicker", 11.5, 0, "kicker")
	obstacle.set_meta("ride_height", 1.45)

	var ramp_mesh = PrismMesh.new()
	ramp_mesh.size = Vector3(5.0, 1.4, 7.0)
	var ramp = _create_mesh("Ramp", ramp_mesh, Color(0.95, 0.83, 0.28))
	ramp.position.y = WATERLINE_Y + 0.7
	obstacle.add_child(ramp)

	var deck_mesh = BoxMesh.new()
	deck_mesh.size = Vector3(5.2, 0.18, 7.2)
	var deck = _create_mesh("Deck", deck_mesh, Color(0.18, 0.18, 0.16))
	deck.position.y = WATERLINE_Y + 1.45
	obstacle.add_child(deck)
	return obstacle

static func create_flat_box() -> Node3D:
	var obstacle = _create_obstacle_root("FlatBox", "grind", 12.0, 150, "flat_box")
	obstacle.set_meta("ride_height", 0.92)

	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(4.0, 0.8, 12.0)
	var box = _create_mesh("RideSurface", box_mesh, Color(0.95, 0.83, 0.28))
	box.position.y = WATERLINE_Y + 0.4
	obstacle.add_child(box)

	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(4.1, 0.08, 12.1)
	var top = _create_mesh("TopSheet", top_mesh, Color(0.18, 0.18, 0.16))
	top.position.y = WATERLINE_Y + 0.84
	obstacle.add_child(top)
	return obstacle

static func create_table_long() -> Node3D:
	var obstacle = _create_obstacle_root("TableLong", "grind", 18.0, 250, "table_long")
	obstacle.set_meta("ride_height", 0.95)

	var table_mesh = BoxMesh.new()
	table_mesh.size = Vector3(5.0, 0.85, 18.0)
	var table = _create_mesh("RideSurface", table_mesh, Color(0.95, 0.83, 0.28))
	table.position.y = WATERLINE_Y + 0.42
	obstacle.add_child(table)

	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(5.15, 0.08, 18.15)
	var top = _create_mesh("TopSheet", top_mesh, Color(0.18, 0.18, 0.16))
	top.position.y = WATERLINE_Y + 0.88
	obstacle.add_child(top)
	return obstacle

static func create_pipe_rail() -> Node3D:
	var obstacle = _create_obstacle_root("PipeRail", "grind", 10.5, 250, "pipe_rail")
	obstacle.set_meta("ride_height", 0.95)

	var rail_mesh = CylinderMesh.new()
	rail_mesh.top_radius = 0.18
	rail_mesh.bottom_radius = 0.18
	rail_mesh.height = 10.0
	var rail = _create_mesh("Pipe", rail_mesh, Color(0.1, 0.1, 0.09))
	rail.rotation_degrees.x = 90.0
	rail.position.y = WATERLINE_Y + 0.85
	obstacle.add_child(rail)

	obstacle.add_child(_create_support("LeftSupport", -3.5))
	obstacle.add_child(_create_support("RightSupport", 3.5))
	return obstacle

static func _create_obstacle_root(
	obstacle_name: String,
	obstacle_kind: String,
	interaction_radius: float,
	points: int,
	obstacle_type: String
) -> Node3D:
	var obstacle = Node3D.new()
	obstacle.name = obstacle_name
	obstacle.set_meta("obstacle_type", obstacle_type)
	obstacle.set_meta("obstacle_kind", obstacle_kind)
	obstacle.set_meta("interaction_radius", interaction_radius)
	obstacle.set_meta("points", points)
	return obstacle

static func _create_mesh(mesh_name: String, mesh: Mesh, color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = mesh_name
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _create_material(color)
	return mesh_instance

static func _create_support(support_name: String, z_offset: float) -> MeshInstance3D:
	var support_mesh = CylinderMesh.new()
	support_mesh.top_radius = 0.08
	support_mesh.bottom_radius = 0.08
	support_mesh.height = 0.85
	var support = _create_mesh(support_name, support_mesh, Color(0.12, 0.12, 0.11))
	support.position = Vector3(0.0, WATERLINE_Y + 0.42, z_offset)
	return support

static func _create_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.55
	return material

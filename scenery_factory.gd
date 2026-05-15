class_name SceneryFactory

const GRASS_COLOR = Color(0.42, 0.58, 0.24)
const DRY_GRASS_COLOR = Color(0.72, 0.62, 0.36)
const SAND_COLOR = Color(0.78, 0.67, 0.48)
const TREE_COLOR = Color(0.12, 0.32, 0.16)
const TRUNK_COLOR = Color(0.34, 0.22, 0.12)
const HUT_COLOR = Color(0.22, 0.18, 0.14)
const ROOF_COLOR = Color(0.08, 0.08, 0.07)
const HORIZON_COLOR = Color(0.38, 0.46, 0.36)
const CANOPY_BLUE = Color(0.02, 0.13, 0.55)
const CANOPY_RED = Color(0.88, 0.05, 0.04)
const MIN_WATER_CLEARANCE = 75.0
const COURSE_HALF_WIDTH = 55.0
const COURSE_HALF_LENGTH = 155.0
const MIN_STRUCTURE_DISTANCE_FROM_COURSE_CENTER = 80.0

static func create_wakepark_scene(points: Array) -> Node3D:
	var scene = Node3D.new()
	scene.name = "WakeparkScenery"
	var center = _average_point(points)

	scene.add_child(_create_box("OuterGround", Vector3(980.0, 0.08, 650.0), Vector3(0.0, -0.08, 0.0), DRY_GRASS_COLOR))
	scene.add_child(_create_box("CentralIsland", Vector3(500.0, 0.24, 80.0), Vector3(0.0, 0.04, 0.0), GRASS_COLOR))
	scene.add_child(_create_round_land_cap("IslandFrontCap", Vector3(250.0, 0.06, 0.0), 40.0))
	scene.add_child(_create_round_land_cap("IslandBackCap", Vector3(-250.0, 0.06, 0.0), 40.0))
	scene.add_child(_create_shoreline_band("FrontSandBank", Vector3(680.0, 0.1, 22.0), Vector3(0.0, 0.02, 252.0)))
	scene.add_child(_create_shoreline_band("BackSandBank", Vector3(700.0, 0.1, 22.0), Vector3(8.0, 0.02, -220.0)))
	scene.add_child(_create_shoreline_band("RightServiceBank", Vector3(24.0, 0.1, 430.0), Vector3(356.0, 0.02, 8.0)))
	scene.add_child(_create_shoreline_band("LeftGrassBank", Vector3(22.0, 0.1, 360.0), Vector3(-374.0, 0.02, -4.0)))

	_add_hut_row(scene)
	_add_event_canopy(scene)
	_add_tree_lines(scene)
	_add_distant_mountains(scene)
	_add_wind_turbines(scene)
	return scene

static func _add_hut_row(scene: Node3D):
	for index in range(5):
		var hut = _create_hut("LakeHut" + str(index + 1))
		hut.position = Vector3(364.0, 0.0, -86.0 + index * 34.0)
		hut.rotation_degrees.y = -8.0
		_add_structure_on_land(scene, hut)

static func _add_event_canopy(scene: Node3D):
	var canopy = Node3D.new()
	canopy.name = "EventCanopy"
	canopy.position = Vector3(-132.0, 0.0, 268.0)
	canopy.add_child(_create_box("CanopyTop", Vector3(24.0, 0.5, 24.0), Vector3.ZERO + Vector3(0.0, 5.4, 0.0), CANOPY_BLUE))
	canopy.add_child(_create_box("CanopyAccent", Vector3(6.0, 0.56, 24.2), Vector3(0.0, 5.42, 0.0), CANOPY_RED))

	for x_offset in [-10.0, 10.0]:
		for z_offset in [-10.0, 10.0]:
			canopy.add_child(_create_pole("CanopyPole", Vector3(x_offset, 2.6, z_offset), 5.2))

	_add_structure_on_land(scene, canopy)

static func _add_tree_lines(scene: Node3D):
	for index in range(9):
		_add_tree_on_land(scene, "BackTree" + str(index + 1), Vector3(-280.0 + index * 70.0, 0.0, -220.0))

	for index in range(7):
		_add_tree_on_land(scene, "LeftTree" + str(index + 1), Vector3(-374.0, 0.0, -140.0 + index * 46.0))

static func _add_tree_on_land(scene: Node3D, tree_name: String, position: Vector3):
	if _is_inside_course_perimeter(position):
		return
	scene.add_child(_create_tree(tree_name, position))

static func _is_inside_course_perimeter(position: Vector3) -> bool:
	return abs(position.x) <= COURSE_HALF_WIDTH and abs(position.z) <= COURSE_HALF_LENGTH

static func _add_distant_mountains(scene: Node3D):
	var mountain_line = Node3D.new()
	mountain_line.name = "DistantMountainLine"
	mountain_line.position = Vector3(-110.0, 0.0, -300.0)

	for index in range(4):
		var ridge = _create_box("MountainRidge" + str(index + 1), Vector3(56.0, 28.0, 8.0), Vector3(index * 42.0, 13.0, 0.0), HORIZON_COLOR)
		ridge.rotation_degrees.z = -18.0 + index * 10.0
		mountain_line.add_child(ridge)

	scene.add_child(mountain_line)

static func _add_wind_turbines(scene: Node3D):
	for index in range(3):
		var turbine = _create_wind_turbine("WindTurbine" + str(index + 1))
		turbine.position = Vector3(132.0 + index * 72.0, 0.0, -292.0 + index * 10.0)
		_add_structure_on_land(scene, turbine)

static func _add_structure_on_land(scene: Node3D, structure: Node3D):
	if not _is_outer_land_position(structure.position):
		return
	scene.add_child(structure)

static func _is_outer_land_position(position: Vector3) -> bool:
	return not _is_inside_course_perimeter(position) and _course_center_distance(position) >= MIN_STRUCTURE_DISTANCE_FROM_COURSE_CENTER

static func _course_center_distance(position: Vector3) -> float:
	return Vector2(position.x, position.z).length()

static func _create_hut(hut_name: String) -> Node3D:
	var hut = Node3D.new()
	hut.name = hut_name
	hut.add_child(_create_box("Cabin", Vector3(13.0, 3.2, 8.0), Vector3(0.0, 1.6, 0.0), HUT_COLOR))
	hut.add_child(_create_box("Roof", Vector3(15.0, 0.55, 9.6), Vector3(0.0, 3.55, 0.0), ROOF_COLOR))
	hut.add_child(_create_box("Deck", Vector3(15.0, 0.25, 4.0), Vector3(0.0, 0.18, 5.8), SAND_COLOR))
	return hut

static func _create_tree(tree_name: String, position: Vector3) -> Node3D:
	var tree = Node3D.new()
	tree.name = tree_name
	tree.position = position
	tree.add_child(_create_pole("Trunk", Vector3(0.0, 2.0, 0.0), 4.0, 0.24, TRUNK_COLOR))

	var crown_mesh = SphereMesh.new()
	crown_mesh.radius = 2.6
	crown_mesh.height = 4.2
	var crown = _create_mesh("Crown", crown_mesh, TREE_COLOR)
	crown.position.y = 5.0
	tree.add_child(crown)
	return tree

static func _create_wind_turbine(turbine_name: String) -> Node3D:
	var turbine = Node3D.new()
	turbine.name = turbine_name
	turbine.add_child(_create_pole("Mast", Vector3(0.0, 13.0, 0.0), 26.0, 0.32, Color(0.86, 0.86, 0.82)))
	turbine.add_child(_create_box("Hub", Vector3(1.6, 1.6, 1.6), Vector3(0.0, 26.0, 0.0), Color(0.86, 0.86, 0.82)))

	for angle in [0.0, 120.0, 240.0]:
		var blade = _create_box("Blade", Vector3(0.45, 9.0, 0.16), Vector3(0.0, 30.5, 0.0), Color(0.9, 0.9, 0.86))
		blade.rotation_degrees.z = angle
		turbine.add_child(blade)

	return turbine

static func _create_round_land_cap(cap_name: String, position: Vector3, radius: float) -> MeshInstance3D:
	var cap_mesh = CylinderMesh.new()
	cap_mesh.top_radius = radius
	cap_mesh.bottom_radius = radius
	cap_mesh.height = 0.24
	var cap = _create_mesh(cap_name, cap_mesh, GRASS_COLOR)
	cap.position = position
	return cap

static func _create_shoreline_band(band_name: String, size: Vector3, position: Vector3) -> MeshInstance3D:
	return _create_box(band_name, size, position, SAND_COLOR)

static func _create_pole(
	pole_name: String,
	position: Vector3,
	height: float,
	radius: float = 0.12,
	color: Color = Color(0.84, 0.84, 0.78)
) -> MeshInstance3D:
	var pole_mesh = CylinderMesh.new()
	pole_mesh.top_radius = radius
	pole_mesh.bottom_radius = radius
	pole_mesh.height = height
	return _create_positioned_mesh(pole_name, pole_mesh, position, color)

static func _create_box(box_name: String, size: Vector3, position: Vector3, color: Color) -> MeshInstance3D:
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	return _create_positioned_mesh(box_name, box_mesh, position, color)

static func _create_positioned_mesh(mesh_name: String, mesh: Mesh, position: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance = _create_mesh(mesh_name, mesh, color)
	mesh_instance.position = position
	return mesh_instance

static func _create_mesh(mesh_name: String, mesh: Mesh, color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = mesh_name
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _create_material(color)
	return mesh_instance

static func _create_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	return material

static func _average_point(points: Array) -> Vector3:
	var total = Vector3.ZERO
	for point in points:
		total += point
	return total / points.size()

class_name EnvironmentFactory

const STEEL_COLOR = Color(0.78, 0.82, 0.82)
const DARK_STEEL_COLOR = Color(0.06, 0.06, 0.06)
const WARNING_COLOR = Color(1.0, 0.16, 0.08)

static func create_daytime_world_environment() -> WorldEnvironment:
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.26, 0.57, 1.0)
	sky_material.sky_horizon_color = Color(0.92, 0.97, 1.0)
	sky_material.ground_bottom_color = Color(0.32, 0.46, 0.34)
	sky_material.ground_horizon_color = Color(0.92, 0.97, 1.0)
	sky_material.energy_multiplier = 1.1
	sky_material.sun_angle_max = 32.0
	sky_material.sun_curve = 0.08

	var sky = Sky.new()
	sky.sky_material = sky_material

	var environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.85

	var world_environment = WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	world_environment.environment = environment
	return world_environment

static func create_engine_tower(tower_name: String) -> Node3D:
	var tower = Node3D.new()
	tower.name = tower_name
	_add_engine_tower_frame(tower)
	_add_engine_head(tower)
	return tower

static func create_corner_tower(tower_name: String) -> Node3D:
	var tower = Node3D.new()
	tower.name = tower_name
	_add_corner_tower_frame(tower)
	_add_pulley_head(tower, Vector3(0.0, 10.8, -7.0))
	return tower

static func create_course_marker(marker_name: String) -> MeshInstance3D:
	var buoy_mesh = SphereMesh.new()
	buoy_mesh.radius = 0.8
	buoy_mesh.height = 1.0
	var marker = _create_mesh(marker_name, buoy_mesh, WARNING_COLOR)
	marker.position.y = 0.35
	return marker

static func _add_engine_tower_frame(tower: Node3D):
	var base_left = Vector3(-2.0, 0.0, 4.0)
	var base_right = Vector3(2.0, 0.0, 4.0)
	var apex_left = Vector3(-1.0, 11.0, -8.0)
	var apex_right = Vector3(1.0, 11.0, -8.0)
	_add_truss_frame(tower, base_left, base_right, apex_left, apex_right, 4)

	var boom_start = Vector3(0.0, 10.5, -6.8)
	var boom_end = Vector3(0.0, 10.5, -19.0)
	tower.add_child(_beam_between("EngineBoom", boom_start, boom_end, 0.22, DARK_STEEL_COLOR))
	tower.add_child(_beam_between("BoomBraceLeft", apex_left, boom_end, 0.12, STEEL_COLOR))
	tower.add_child(_beam_between("BoomBraceRight", apex_right, boom_end, 0.12, STEEL_COLOR))

static func _add_engine_head(tower: Node3D):
	var deck_mesh = BoxMesh.new()
	deck_mesh.size = Vector3(3.2, 0.22, 2.2)
	var deck = _create_mesh("EngineDeck", deck_mesh, DARK_STEEL_COLOR)
	deck.position = Vector3(0.0, 9.4, -15.5)
	tower.add_child(deck)

	var motor_mesh = BoxMesh.new()
	motor_mesh.size = Vector3(2.2, 1.0, 1.4)
	var motor = _create_mesh("MotorHousing", motor_mesh, DARK_STEEL_COLOR)
	motor.position = Vector3(0.0, 10.05, -15.2)
	tower.add_child(motor)

	for index in range(3):
		var pulley = _create_pulley("EnginePulley" + str(index + 1))
		pulley.position = Vector3(-1.0 + index, 10.65, -18.7)
		tower.add_child(pulley)

static func _add_corner_tower_frame(tower: Node3D):
	var base_left = Vector3(-1.4, 0.0, 3.0)
	var base_right = Vector3(1.4, 0.0, 3.0)
	var apex_left = Vector3(-0.7, 10.8, -7.0)
	var apex_right = Vector3(0.7, 10.8, -7.0)
	_add_truss_frame(tower, base_left, base_right, apex_left, apex_right, 4)

	var boom_end = Vector3(0.0, 10.6, -10.5)
	tower.add_child(_beam_between("ShortCableArm", Vector3(0.0, 10.6, -6.4), boom_end, 0.16, DARK_STEEL_COLOR))
	tower.add_child(_beam_between("CableArmBraceLeft", apex_left, boom_end, 0.1, STEEL_COLOR))
	tower.add_child(_beam_between("CableArmBraceRight", apex_right, boom_end, 0.1, STEEL_COLOR))

static func _add_pulley_head(tower: Node3D, center: Vector3):
	var deck_mesh = BoxMesh.new()
	deck_mesh.size = Vector3(2.4, 0.18, 1.2)
	var deck = _create_mesh("PulleyDeck", deck_mesh, DARK_STEEL_COLOR)
	deck.position = center + Vector3(0.0, -0.55, -0.6)
	tower.add_child(deck)

	for index in range(2):
		var pulley = _create_pulley("CornerPulley" + str(index + 1))
		pulley.position = center + Vector3(-0.45 + index * 0.9, 0.0, -1.2)
		tower.add_child(pulley)

static func _add_truss_frame(
	tower: Node3D,
	base_left: Vector3,
	base_right: Vector3,
	apex_left: Vector3,
	apex_right: Vector3,
	sections: int
):
	tower.add_child(_beam_between("LeftMainLeg", base_left, apex_left, 0.14, STEEL_COLOR))
	tower.add_child(_beam_between("RightMainLeg", base_right, apex_right, 0.14, STEEL_COLOR))
	tower.add_child(_beam_between("TopCrossBar", apex_left, apex_right, 0.1, STEEL_COLOR))

	for index in range(sections):
		var start_amount = float(index) / sections
		var end_amount = float(index + 1) / sections
		var left_start = base_left.lerp(apex_left, start_amount)
		var left_end = base_left.lerp(apex_left, end_amount)
		var right_start = base_right.lerp(apex_right, start_amount)
		var right_end = base_right.lerp(apex_right, end_amount)
		tower.add_child(_beam_between("CrossBraceA" + str(index), left_start, right_end, 0.07, STEEL_COLOR))
		tower.add_child(_beam_between("CrossBraceB" + str(index), right_start, left_end, 0.07, STEEL_COLOR))
		tower.add_child(_beam_between("Rung" + str(index), left_start, right_start, 0.07, STEEL_COLOR))

static func _create_pulley(pulley_name: String) -> MeshInstance3D:
	var pulley_mesh = CylinderMesh.new()
	pulley_mesh.top_radius = 0.48
	pulley_mesh.bottom_radius = 0.48
	pulley_mesh.height = 0.16
	var pulley = _create_mesh(pulley_name, pulley_mesh, DARK_STEEL_COLOR)
	pulley.rotation_degrees.z = 90.0
	return pulley

static func _beam_between(
	beam_name: String,
	start: Vector3,
	end: Vector3,
	thickness: float,
	color: Color
) -> MeshInstance3D:
	var direction = end - start
	var beam_mesh = BoxMesh.new()
	beam_mesh.size = Vector3(thickness, thickness, direction.length())
	var beam = _create_mesh(beam_name, beam_mesh, color)
	beam.position = start + direction * 0.5
	beam.look_at_from_position(beam.position, end, _up_for_direction(direction))
	return beam

static func _up_for_direction(direction: Vector3) -> Vector3:
	if abs(direction.normalized().dot(Vector3.UP)) > 0.95:
		return Vector3.FORWARD
	return Vector3.UP

static func _create_mesh(mesh_name: String, mesh: Mesh, color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = mesh_name
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _create_material(color)
	return mesh_instance

static func _create_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.6
	return material

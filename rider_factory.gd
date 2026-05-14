class_name RiderFactory

const BOARD_BLACK = Color(0.02, 0.02, 0.02)
const BOARD_WHITE = Color(0.92, 0.92, 0.96)
const BOARD_PURPLE = Color(0.35, 0.16, 0.78)
const VEST_RED = Color(0.9, 0.16, 0.12)
const SHIRT_DARK = Color(0.04, 0.05, 0.06)
const SHORTS_DARK = Color(0.08, 0.08, 0.1)
const SKIN = Color(0.48, 0.29, 0.18)
const HELMET_RED = Color(0.82, 0.1, 0.12)
const ROPE_COLOR = Color(0.9, 0.9, 0.82)

static func populate(root: Node3D):
	root.name = "RiderVisual"
	if root is MeshInstance3D:
		root.mesh = null

	root.add_child(_create_board())
	root.add_child(_create_body())
	root.add_child(_create_rope_and_handle())

static func _create_board() -> Node3D:
	var board = Node3D.new()
	board.name = "Wakeboard"
	board.add_child(_create_box("BoardCenter", Vector3(1.05, 0.08, 2.15), Vector3(0.0, 0.0, 0.0), BOARD_BLACK))
	board.add_child(_create_board_cap("BoardNose", Vector3(0.0, 0.0, -1.08)))
	board.add_child(_create_board_cap("BoardTail", Vector3(0.0, 0.0, 1.08)))
	board.add_child(_create_box("WhiteCenterGraphic", Vector3(0.22, 0.02, 1.45), Vector3(0.0, 0.06, 0.0), BOARD_WHITE))
	board.add_child(_create_box("PurpleAccentGraphic", Vector3(0.12, 0.025, 1.0), Vector3(0.24, 0.07, 0.0), BOARD_PURPLE))
	board.add_child(_create_box("TopCloudGraphic", Vector3(0.55, 0.025, 0.22), Vector3(0.0, 0.08, -0.74), BOARD_WHITE))
	board.add_child(_create_box("BottomCloudGraphic", Vector3(0.55, 0.025, 0.22), Vector3(0.0, 0.08, 0.74), BOARD_WHITE))
	board.add_child(_create_box("FrontBinding", Vector3(0.42, 0.22, 0.38), Vector3(-0.22, 0.18, -0.42), BOARD_WHITE))
	board.add_child(_create_box("BackBinding", Vector3(0.42, 0.22, 0.38), Vector3(0.22, 0.18, 0.42), BOARD_WHITE))
	return board

static func _create_body() -> Node3D:
	var body = Node3D.new()
	body.name = "RiderBody"
	body.add_child(_create_box("Hips", Vector3(0.58, 0.34, 0.34), Vector3(0.0, 0.95, 0.0), SHORTS_DARK))
	body.add_child(_create_box("Torso", Vector3(0.64, 0.84, 0.34), Vector3(0.0, 1.55, -0.08), SHIRT_DARK))
	body.add_child(_create_box("LifeVest", Vector3(0.7, 0.68, 0.4), Vector3(0.0, 1.58, -0.11), VEST_RED))
	body.add_child(_create_head())
	_add_legs(body)
	_add_arms(body)
	body.rotation_degrees.x = -11.0
	body.rotation_degrees.z = -8.0
	return body

static func _create_head() -> MeshInstance3D:
	var head_mesh = SphereMesh.new()
	head_mesh.radius = 0.25
	head_mesh.height = 0.34
	var head = _create_mesh("Helmet", head_mesh, HELMET_RED)
	head.position = Vector3(0.0, 2.18, -0.22)
	return head

static func _add_legs(body: Node3D):
	body.add_child(_create_limb("FrontLeg", Vector3(0.16, 0.55, -0.42), Vector3(0.18, 0.7, 0.16), SKIN, -14.0))
	body.add_child(_create_limb("BackLeg", Vector3(-0.16, 0.55, 0.42), Vector3(0.18, 0.7, 0.16), SKIN, 14.0))
	body.add_child(_create_box("FrontBoot", Vector3(0.34, 0.18, 0.28), Vector3(0.2, 0.28, -0.55), BOARD_WHITE))
	body.add_child(_create_box("BackBoot", Vector3(0.34, 0.18, 0.28), Vector3(-0.2, 0.28, 0.55), BOARD_WHITE))

static func _add_arms(body: Node3D):
	body.add_child(_create_limb("HandleArm", Vector3(0.38, 1.42, -0.32), Vector3(0.16, 0.72, 0.14), SHIRT_DARK, -38.0))
	body.add_child(_create_limb("BalanceArm", Vector3(-0.46, 1.35, 0.16), Vector3(0.14, 0.72, 0.14), SHIRT_DARK, 52.0))

static func _create_rope_and_handle() -> Node3D:
	var rig = Node3D.new()
	rig.name = "HandleAndRope"
	rig.add_child(_create_box("Handle", Vector3(0.8, 0.08, 0.08), Vector3(0.55, 1.35, -0.62), Color(0.03, 0.03, 0.03)))
	var rope = _create_limb("TowRope", Vector3(0.56, 4.9, -2.3), Vector3(0.035, 7.4, 0.035), ROPE_COLOR, -22.0)
	rope.rotation_degrees.x = 18.0
	rig.add_child(rope)
	return rig

static func _create_limb(limb_name: String, position: Vector3, size: Vector3, color: Color, z_rotation: float) -> MeshInstance3D:
	var limb = _create_box(limb_name, size, position, color)
	limb.rotation_degrees.z = z_rotation
	return limb

static func _create_board_cap(cap_name: String, position: Vector3) -> MeshInstance3D:
	var cap_mesh = CylinderMesh.new()
	cap_mesh.top_radius = 0.54
	cap_mesh.bottom_radius = 0.54
	cap_mesh.height = 0.08
	var cap = _create_mesh(cap_name, cap_mesh, BOARD_BLACK)
	cap.position = position
	cap.scale.z = 0.48
	return cap

static func _create_box(box_name: String, size: Vector3, position: Vector3, color: Color) -> MeshInstance3D:
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	var box = _create_mesh(box_name, box_mesh, color)
	box.position = position
	return box

static func _create_mesh(mesh_name: String, mesh: Mesh, color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = mesh_name
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _create_material(color)
	return mesh_instance

static func _create_material(color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.62
	return material

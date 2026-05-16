extends CanvasLayer

const ObstacleFactoryScript = preload("res://obstacle_factory.gd")
const ObstacleSpawnerScript = preload("res://obstacle_spawner.gd")

var score = 0
var trick_display_timer = 0.0
var trick_display_duration = 2.0
var selected_obstacle_type = ""
var active_obstacle: Node3D
var is_dragging_obstacle = false
var remove_mode = false
var arrange_mode = false
var was_paused_before_menu = false
var camera_saved_transform = Transform3D.IDENTITY
var camera_saved_fov = 75.0

@onready var trick_label: Label = $TrickLabel
@onready var score_label: Label = $ScoreLabel

var pause_button: Button
var overlay: Control
var menu_panel: VBoxContainer
var select_panel: VBoxContainer
var arrange_panel: VBoxContainer
var counter_label: Label
var arrange_counter_label: Label
var arrange_toggle: CheckButton
var remove_button: Button
var rotate_button: Button

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	trick_label.text = ""
	score_label.text = "Score: 0"
	ObstacleSpawnerScript.load_layout()
	_build_pause_button()
	_build_overlay()
	_update_counter()

func _process(delta):
	if trick_display_timer > 0:
		trick_display_timer -= delta
		if trick_display_timer <= 0:
			trick_label.text = ""

func _input(event):
	if not arrange_mode:
		return
	if event is InputEventMouseButton:
		_handle_pointer_button(event.position, event.pressed)
	elif event is InputEventMouseMotion and is_dragging_obstacle:
		_drag_to_screen(event.position)
	elif event is InputEventScreenTouch:
		_handle_pointer_button(event.position, event.pressed)
	elif event is InputEventScreenDrag and is_dragging_obstacle:
		_drag_to_screen(event.position)

func show_trick(trick_name: String, points: int):
	score += points
	trick_label.text = trick_name + "\n+" + str(points)
	score_label.text = "Score: " + str(score)
	trick_display_timer = trick_display_duration

func show_obstacle(message: String, points: int):
	score += points
	if points > 0:
		trick_label.text = message + "\n+" + str(points)
	else:
		trick_label.text = message
	score_label.text = "Score: " + str(score)
	trick_display_timer = trick_display_duration

func crash():
	score = 0
	score_label.text = "Score: 0"
	trick_label.text = "CRASHED!"
	trick_display_timer = trick_display_duration

func _build_pause_button():
	pause_button = Button.new()
	pause_button.text = "||"
	pause_button.tooltip_text = "Pause"
	pause_button.anchor_left = 1.0
	pause_button.anchor_right = 1.0
	pause_button.offset_left = -64.0
	pause_button.offset_top = 16.0
	pause_button.offset_right = -16.0
	pause_button.offset_bottom = 56.0
	pause_button.pressed.connect(_open_settings_menu)
	add_child(pause_button)

func _build_overlay():
	overlay = Control.new()
	overlay.visible = false
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	overlay.add_child(margin)

	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	menu_panel = _make_panel(root)
	select_panel = _make_panel(root)
	arrange_panel = _make_panel(root)
	_build_settings_panel()
	_build_selection_panel()
	_build_arrange_panel()
	_show_menu_panel()

func _build_settings_panel():
	menu_panel.add_child(_make_title("Settings"))
	menu_panel.add_child(_make_button("Resume", _resume_game))
	arrange_toggle = CheckButton.new()
	arrange_toggle.text = "Obstacle Arrange Mode"
	arrange_toggle.custom_minimum_size = Vector2(220, 40)
	arrange_toggle.toggled.connect(_toggle_arrange_system)
	menu_panel.add_child(arrange_toggle)
	menu_panel.add_child(_make_button("Exit", _exit_game))

func _build_selection_panel():
	select_panel.add_child(_make_title("Select Obstacle"))
	counter_label = _make_title("")
	select_panel.add_child(counter_label)
	for data in ObstacleFactoryScript.get_available_obstacles():
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var label = Label.new()
		label.text = str(data["label"])
		label.custom_minimum_size = Vector2(130, 32)
		row.add_child(label)
		var button = Button.new()
		button.text = "Select"
		button.pressed.connect(_select_obstacle.bind(str(data["type"])))
		row.add_child(button)
		select_panel.add_child(row)
	select_panel.add_child(_make_button("Back", _show_menu_panel))

func _build_arrange_panel():
	arrange_panel.add_child(_make_title("Arrange Obstacles"))
	arrange_counter_label = _make_title("")
	arrange_panel.add_child(arrange_counter_label)
	var hint = Label.new()
	hint.text = "Drag on water. Snap points lock within 8 m."
	arrange_panel.add_child(hint)
	rotate_button = _make_button("Rotate 45", _rotate_dragged_obstacle)
	remove_button = _make_button("Remove Mode: Off", _toggle_remove_mode)
	arrange_panel.add_child(rotate_button)
	arrange_panel.add_child(remove_button)
	arrange_panel.add_child(_make_button("Done", _finish_arrange_mode))

func _make_panel(parent: Control) -> VBoxContainer:
	var panel = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(280, 0)
	panel.add_theme_constant_override("separation", 8)
	parent.add_child(panel)
	return panel

func _make_title(text: String) -> Label:
	var label = Label.new()
	label.text = text
	return label

func _make_button(text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(160, 40)
	button.pressed.connect(callback)
	return button

func _open_settings_menu():
	was_paused_before_menu = get_tree().paused
	get_tree().paused = true
	overlay.visible = true
	_show_menu_panel()

func _resume_game():
	_exit_arrange_camera()
	_set_gameplay_labels_visible(true)
	arrange_mode = false
	overlay.visible = false
	if arrange_toggle:
		arrange_toggle.button_pressed = false
	get_tree().paused = was_paused_before_menu

func _open_obstacle_selection():
	arrange_mode = false
	_set_gameplay_labels_visible(false)
	_enter_arrange_camera()
	_show_selection_panel()

func _toggle_arrange_system(enabled: bool):
	if enabled:
		_open_obstacle_selection()

func _select_obstacle(obstacle_type: String):
	if ObstacleSpawnerScript.get_obstacle_count() >= ObstacleSpawnerScript.MAX_OBSTACLES:
		return
	selected_obstacle_type = obstacle_type
	active_obstacle = ObstacleSpawnerScript.add_obstacle(obstacle_type, Vector3.ZERO, 0.0, false)
	is_dragging_obstacle = true
	arrange_mode = true
	remove_mode = false
	_show_arrange_panel()
	_update_counter()

func _finish_arrange_mode():
	ObstacleSpawnerScript.save_layout()
	active_obstacle = null
	is_dragging_obstacle = false
	selected_obstacle_type = ""
	arrange_mode = false
	_set_gameplay_labels_visible(true)
	_exit_arrange_camera()
	_show_selection_panel()

func _toggle_remove_mode():
	remove_mode = not remove_mode
	active_obstacle = null
	is_dragging_obstacle = false
	remove_button.text = "Remove Mode: " + ("On" if remove_mode else "Off")

func _rotate_dragged_obstacle():
	if active_obstacle == null:
		return
	active_obstacle.rotation_degrees.y = wrapf(active_obstacle.rotation_degrees.y + 45.0, 0.0, 360.0)
	ObstacleSpawnerScript.save_layout()

func _handle_pointer_button(screen_position: Vector2, pressed: bool):
	if not pressed:
		if active_obstacle:
			ObstacleSpawnerScript.save_layout()
		is_dragging_obstacle = false
		return

	var water_position = _screen_to_water(screen_position)
	if water_position == null:
		return
	if remove_mode:
		var obstacle = ObstacleSpawnerScript.find_obstacle_near(water_position)
		ObstacleSpawnerScript.remove_obstacle(obstacle)
		_update_counter()
		return
	if active_obstacle == null:
		active_obstacle = ObstacleSpawnerScript.find_obstacle_near(water_position)
	is_dragging_obstacle = active_obstacle != null
	_drag_to_position(water_position)

func _drag_to_screen(screen_position: Vector2):
	var water_position = _screen_to_water(screen_position)
	if water_position != null:
		_drag_to_position(water_position)

func _drag_to_position(water_position: Vector3):
	if active_obstacle == null:
		return
	active_obstacle.position = ObstacleSpawnerScript.get_nearest_snap(water_position)

func _screen_to_water(screen_position: Vector2):
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return null
	var origin = camera.project_ray_origin(screen_position)
	var direction = camera.project_ray_normal(screen_position)
	return Plane(Vector3.UP, 0.0).intersects_ray(origin, direction)

func _enter_arrange_camera():
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return
	camera_saved_transform = camera.global_transform
	camera_saved_fov = camera.fov
	camera.global_position = Vector3(0.0, 250.0, 0.0)
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	camera.fov = 55.0

func _exit_arrange_camera():
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return
	camera.global_transform = camera_saved_transform
	camera.fov = camera_saved_fov

func _set_gameplay_labels_visible(is_visible: bool):
	var score_node = get_node_or_null("/root/Main/UI/ScoreLabel")
	var trick_node = get_node_or_null("/root/Main/UI/TrickLabel")
	if score_node:
		score_node.visible = is_visible
	if trick_node:
		trick_node.visible = is_visible

func _show_menu_panel():
	if arrange_toggle:
		arrange_toggle.button_pressed = false
	menu_panel.visible = true
	select_panel.visible = false
	arrange_panel.visible = false

func _show_selection_panel():
	_update_counter()
	menu_panel.visible = false
	select_panel.visible = true
	arrange_panel.visible = false

func _show_arrange_panel():
	_update_counter()
	menu_panel.visible = false
	select_panel.visible = false
	arrange_panel.visible = true

func _update_counter():
	var counter_text = str(ObstacleSpawnerScript.get_obstacle_count()) + "/" + str(ObstacleSpawnerScript.MAX_OBSTACLES) + " obstacles placed"
	if counter_label:
		counter_label.text = counter_text
	if arrange_counter_label:
		arrange_counter_label.text = counter_text

func _exit_game():
	get_tree().quit()

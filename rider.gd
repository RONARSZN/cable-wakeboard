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

func jump():
	if not is_jumping:
		is_jumping = true
		jump_velocity = jump_force
		last_trick = ""
		last_trick_points = 0

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
				 

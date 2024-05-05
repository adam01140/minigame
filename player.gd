extends RigidBody2D

@export var speed: int = 400  # Increased speed for better force application
@export var rectangle_scene = preload("res://Rectangle.tscn")  # Path to the rectangle scene.

func _ready():
	# Adjust physics properties for better control
	mass = 1.0  # Ensure the mass is reasonable
	linear_damp = 0.1  # Lower damping can help with movement fluidity
	angular_damp = 0.1
	set_physics_process(true)

func _physics_process(delta: float):
	var motion = Vector2.ZERO
	
	# Capture player input to determine movement direction.
	if Input.is_action_pressed("ui_right"):
		motion.x += 1
	if Input.is_action_pressed("ui_left"):
		motion.x -= 1
	if Input.is_action_pressed("ui_down"):
		motion.y += 1
	if Input.is_action_pressed("ui_up"):
		motion.y -= 1

	# Normalize and scale the motion vector
	motion = motion.normalized() * speed * delta

	# Apply the motion as an impulse
	if motion.length() > 0:
		apply_central_impulse(motion)

	# Debug output to help diagnose movement issues
	print("Velocity: ", linear_velocity, " Motion: ", motion)

func check_arena_bounds():
	var arena_node = get_parent().get_node("Arena") as Sprite2D
	if arena_node and arena_node.texture:
		var arena_size = arena_node.texture.get_size()
		if position.x < 0 or position.x > arena_size.x or position.y < 0 or position.y > arena_size.y:
			queue_free()  # Remove the player from the scene if they fall off

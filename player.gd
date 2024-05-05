extends RigidBody2D

@export var speed: int = 200  # Speed of the player in pixels per second.
@export var rectangle_scene = preload("res://Rectangle.tscn")  # Path to the rectangle scene.




func _process(delta: float) -> void:
	var motion: Vector2 = Vector2()
	
	# Capture player input to determine movement direction.
	if Input.is_action_pressed("ui_right"):
		motion.x += 1
	if Input.is_action_pressed("ui_left"):
		motion.x -= 1
	if Input.is_action_pressed("ui_down"):
		motion.y += 1
	if Input.is_action_pressed("ui_up"):
		motion.y -= 1
	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

	# Normalize the motion vector so diagonal movement isn't faster.
	motion = motion.normalized() * speed * delta

	# Update the player's position.
	position += motion

	# Access the 'Arena' sprite node and check dimensions.
	var arena_node = get_parent().get_node("Arena") as Sprite2D
	if arena_node and arena_node.texture:
		var arena_size = arena_node.texture.get_size()
		var arena_width = arena_size.x
		var arena_height = arena_size.y

		# Check if the player has moved outside the bounds of the arena.
		if position.x < 0 or position.x > arena_width or position.y < 0 or position.y > arena_height:
			queue_free()  # Remove the player from the scene if they fall off.

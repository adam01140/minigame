extends RigidBody2D

@export var speed: float = 200
@export var rectangle_scene_path: String = "res://Rectangle.tscn"

func _process(delta: float) -> void:
	var motion := Vector2.ZERO
	motion = handle_input(motion)  # Get the updated motion vector
	move_player(motion, delta)
	check_arena_bounds()

func handle_input(motion: Vector2) -> Vector2:
	if Input.is_action_pressed("player2_right"):
		motion.x += 1
	if Input.is_action_pressed("player2_left"):
		motion.x -= 1
	if Input.is_action_pressed("player2_down"):
		motion.y += 1
	if Input.is_action_pressed("player2_up"):
		motion.y -= 1
	if Input.is_action_just_pressed("player2_up"):
		spawn_rectangle()
		# motion.y += 1 # This line seems redundant and could cause unexpected movement.
	return motion  # Return the updated motion vector


func move_player(motion: Vector2, delta: float) -> void:
	motion = motion.normalized() * speed * delta
	position += motion

func check_arena_bounds() -> void:
	var arena_node := get_parent().get_node("Arena") as Sprite2D
	if arena_node and arena_node.texture:
		var arena_size := arena_node.texture.get_size()
		if position.x < 0 or position.x > arena_size.x or position.y < 0 or position.y > arena_size.y:
			queue_free()

func spawn_rectangle() -> void:
	var rectangle_scene = load(rectangle_scene_path)  # Load the scene when needed.
	if rectangle_scene is PackedScene:
		var direction = Vector2.ZERO
		if Input.is_action_pressed("player2_right"):
			direction = Vector2.RIGHT
		elif Input.is_action_pressed("player2_left"):
			direction = Vector2.LEFT
		elif Input.is_action_pressed("player2_down"):
			direction = Vector2.DOWN
		elif Input.is_action_pressed("player2_up"):
			direction = Vector2.UP

		var rectangle: Node2D = rectangle_scene.instantiate() as Node2D  # Explicitly cast to Node2D.
		rectangle.position = position + direction * 50  # Adjust the 50 to your desired distance
		get_parent().add_child(rectangle)

extends CharacterBody2D

# Define collision layers and masks
const PLAYER_COLLISION_LAYER = 1
const PLAYER_COLLISION_MASK = 1

@export var speed: float = 200
@export var rectangle_scene_path: String = "res://Rectangle.tscn"
var last_direction = Vector2.ZERO  # Variable to store the last direction
var spawned_rectangle = null  # Store the rectangle instance

func _ready():
	# Configure collision layer and mask
	set_collision_layer_value(PLAYER_COLLISION_LAYER, true)
	set_collision_mask_value(PLAYER_COLLISION_MASK, true)

func _process(delta: float) -> void:
	var motion := Vector2.ZERO
	motion = handle_input(motion)  # Get the updated motion vector
	move_player(motion, delta)
	check_arena_bounds()
	if spawned_rectangle:
		update_rectangle_position()

func handle_input(motion: Vector2) -> Vector2:
	if Input.is_action_pressed("ui_right"):
		motion.x += 1
	if Input.is_action_pressed("ui_left"):
		motion.x -= 1
	if Input.is_action_pressed("ui_down"):
		motion.y += 1
	if Input.is_action_pressed("ui_up"):
		motion.y -= 1

	if motion != Vector2.ZERO:
		last_direction = motion.normalized()

	if Input.is_action_just_pressed("rect_spawn"):
		spawn_rectangle()

	return motion

func move_player(motion: Vector2, delta: float) -> void:
	motion = motion.normalized() * speed * delta
	position += motion

func check_arena_bounds() -> void:
	var arena_node = get_parent().get_node("Arena") as Sprite2D
	if arena_node and arena_node.texture:
		var arena_size = arena_node.texture.get_size()
		if position.x < 0 or position.x > arena_size.x or position.y < 0 or position.y > arena_size.y:
			queue_free()



func spawn_rectangle() -> void:
	if last_direction == Vector2.ZERO:
		return  # Don't spawn if there's no movement direction

	var rectangle_scene = load(rectangle_scene_path)
	if rectangle_scene is PackedScene:
		spawned_rectangle = rectangle_scene.instantiate() as Node2D
		# Adjust spawn position based on movement direction
		if last_direction.x < 0:
			spawned_rectangle.position = position + last_direction * 100  # Left movement
		elif last_direction.x > 0:
			spawned_rectangle.position = position + last_direction * 200  # Right movement
		else:  # Up or down
			spawned_rectangle.position = position + Vector2(75, 0) + last_direction * 100  # Slightly to the right
		
		get_parent().add_child(spawned_rectangle)
		var timer = Timer.new()
		timer.wait_time = 5
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
		timer.start()


func update_rectangle_position():
	if spawned_rectangle:
		if last_direction.x < 0:
			spawned_rectangle.position = position + Vector2(0, 30) + last_direction * 20  # Left movement
		elif last_direction.x > 0:
			spawned_rectangle.position = position + Vector2(0, 30) + last_direction * 150  # Right movement
		elif last_direction.y > 0:  # Up or down
			spawned_rectangle.position = position + Vector2(75, 0) + last_direction * 100  # Slightly to the right
		elif last_direction.y < 0:  # Up or down
			spawned_rectangle.position = position + Vector2(75, 0) + last_direction * 40  # Slightly to the right
		else:
			spawned_rectangle.position = position + last_direction * 50  # Default case


func _on_timer_timeout():
	if spawned_rectangle:
		spawned_rectangle.queue_free()
		spawned_rectangle = null

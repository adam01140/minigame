extends RigidBody2D

@export var speed: float = 200
@export var rectangle_scene_path: String = "res://Rectangle.tscn"
var last_direction = Vector2.ZERO  # Variable to store the last direction
var spawned_rectangle = null  # Store the rectangle instance
var push = 0
var push1 = 0
var shoot = 0

func _process(delta: float) -> void:
	var motion := Vector2.ZERO
	motion = handle_input(motion)  # Get the updated motion vector
	move_player(motion, delta)
	if spawned_rectangle:
		update_rectangle_position()

func handle_input(motion: Vector2) -> Vector2:
	
	if Player:
		push1 = Player.push1
		
	
	if Input.is_action_pressed("player2_right"):
		
		motion.x += 1
		push = 1
	if Input.is_action_pressed("player2_left"):
		motion.x -= 1
		push = 2
	if Input.is_action_pressed("player2_down"):
		motion.y += 1
		push = 3
	if Input.is_action_pressed("player2_up"):
		motion.y -= 1
		push = 4

	if motion != Vector2.ZERO:
		last_direction = motion.normalized()

	if Input.is_action_just_pressed("rect_spawn") && shoot == 0:
		spawn_rectangle()
		shoot = 1

	return motion

func move_player(motion: Vector2, delta: float) -> void:
	motion = motion.normalized() * speed * delta
	position += motion
	
func _on_area_2d_area_entered(area):
	if area.is_in_group("arena"):
		print("hey")
	if area.is_in_group("inside"):
		queue_free()
			
	if area.is_in_group("block"):
		if push1 == 1:
			position += Vector2(50, 0)
			print(push1)
		if push1 == 2:
			position += Vector2(-50, 0)
			print(push1)
		if push1 == 3:
			position += Vector2(0, 50)
			print(push1)
		if push1 == 4:
			position += Vector2(0, -50)
			print(push1)
			
			
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
		shoot = 0

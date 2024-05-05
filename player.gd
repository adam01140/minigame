extends RigidBody2D
@export var rectangle_scene2_path: String = "res://Rectangle.tscn"




@export var speed: float = 200  # Speed of the player in pixels per second.
@export var rectangle_scene2 = preload("res://Rectangle.tscn")  # Path to the rectangle scene.
var last_direction2 = Vector2.ZERO  # Variable to store the last direction
var spawned_rectangle2 = null  # Store the rectangle instance

@export var last_direction: String = "res://Player2.tscn"
@export var push: String = "res://Player2.tscn"

var push2 = Player2.push


func _process(delta: float) -> void:
	var motion2: Vector2 = Vector2()
	motion2 = handle_input(motion2)  # Get the updated motion2 vector
	move_player(motion2, delta)
	check_arena_bounds()
	if spawned_rectangle2:
		update_rectangle_position()
	
func handle_input(motion2: Vector2) -> Vector2:
	
	push2 = Player2.push
	if Input.is_action_pressed("ui_right"):
		
		motion2.x += 1
	if Input.is_action_pressed("ui_left"):
		motion2.x -= 1
	if Input.is_action_pressed("ui_down"):
		motion2.y += 1
	if Input.is_action_pressed("ui_up"):
		motion2.y -= 1

	if motion2 != Vector2.ZERO:
		last_direction2 = motion2.normalized()

	if Input.is_action_just_pressed("rect_spawn2"):
		spawn_rectangle2()

	return motion2
	
	

func spawn_rectangle2() -> void:
	if last_direction2 == Vector2.ZERO:
		return  # Don't spawn if there's no movement direction

	var rectangle_scene2 = load(rectangle_scene2_path)
	if rectangle_scene2 is PackedScene:
		spawned_rectangle2 = rectangle_scene2.instantiate() as Node2D
		# Adjust spawn position based on movement direction
		if last_direction2.x < 0:
			spawned_rectangle2.position = position + last_direction2 * 100  # Left movement
		elif last_direction2.x > 0:
			spawned_rectangle2.position = position + last_direction2 * 200  # Right movement
		else:  # Up or down
			spawned_rectangle2.position = position + Vector2(75, 0) + last_direction2 * 100  # Slightly to the right
		
		get_parent().add_child(spawned_rectangle2)
		var timer = Timer.new()
		timer.wait_time = 5
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)
		timer.start()


func update_rectangle_position():
	if spawned_rectangle2:
		if last_direction2.x < 0:
			spawned_rectangle2.position = position + Vector2(0, 30) + last_direction2 * 20  # Left movement
		elif last_direction2.x > 0:
			spawned_rectangle2.position = position + Vector2(0, 30) + last_direction2 * 150  # Right movement
		elif last_direction2.y > 0:  # Up or down
			spawned_rectangle2.position = position + Vector2(75, 0) + last_direction2 * 100  # Slightly to the right
		elif last_direction2.y < 0:  # Up or down
			spawned_rectangle2.position = position + Vector2(75, 0) + last_direction2 * 40  # Slightly to the right
		else:
			spawned_rectangle2.position = position + last_direction2 * 50  # Default case


func _on_timer_timeout():
	if spawned_rectangle2:
		spawned_rectangle2.queue_free()
		spawned_rectangle2 = null

	
func move_player(motion2: Vector2, delta: float) -> void:
	motion2 = motion2.normalized() * speed * delta
	position += motion2

func _on_area_2d_area_entered(area):
	if area.is_in_group("arena"):
		print("hey")
		
	if area.is_in_group("block"):
		if push2 == 1:
			position += Vector2(50, 0)
			print(push2)
		if push2 == 2:
			position += Vector2(-50, 0)
			print(push2)
		if push2 == 3:
			position += Vector2(0, 50)
			print(push2)
		if push2 == 4:
			position += Vector2(0, -50)
			print(push2)


func check_arena_bounds() -> void:
	var arena_node = get_parent().get_node("Arena") as Sprite2D
	if arena_node and arena_node.texture:
		var arena_size = arena_node.texture.get_size()
		if position.x < 0 or position.x > arena_size.x or position.y < 0 or position.y > arena_size.y:
			queue_free()
			
			



			
		

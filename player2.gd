extends RigidBody2D

# Exported variables for customization
@export var speed: float = 200
@export var rectangle_scene_path: String = "res://Rectangle.tscn"

# Private variables
var last_direction = Vector2.ZERO  # Variable to store the last direction
var spawned_rectangle = null  # Store the rectangle instance
var push = 0
var shoot = 0  # Control spawning one rectangle at a time
var push2 = 0



var texture_downright = preload("res://downright.png")
var texture_downleft = preload("res://downleft.png")
var texture_upleft = preload("res://upleft.png")
var texture_upright = preload("res://upright.png")


# Preload textures for each direction
var texture_right = preload("res://right.png")
var texture_left = preload("res://left.png")
var texture_pright = preload("res://pright.png")
var texture_pleft = preload("res://pleft.png")
var texture_up = preload("res://up.png")
var texture_down = preload("res://down.png")
var chosen_texture = null  # Variable to hold the chosen texture based on direction
var player_sprite = preload("res://player.tscn")  # Assuming this is your player sprite
var side2 = 0
var up2 = 0

func _process(delta: float) -> void:
	var motion = Vector2.ZERO
	motion = handle_input(motion)  # Get the updated motion vector
	move_player(motion, delta)
	if spawned_rectangle:
		update_rectangle_position()

func handle_input(motion: Vector2) -> Vector2:
	
	side2 = Player.side
	up2 = Player.up
	push2 = Player.push1
	
	
	
	if Input.is_action_pressed("player2_right"):
		motion.x += 50
		push = 1
		chosen_texture = texture_right
		update_player_sprite(texture_pright) 
	
	
	if Input.is_action_pressed("player2_left"):
		motion.x -= 50
		push = 2
		chosen_texture = texture_left
		update_player_sprite(texture_pleft)
	if Input.is_action_pressed("player2_down"):
		motion.y += 50
		push = 3
		chosen_texture = texture_down
		
	if Input.is_action_pressed("player2_up"):
		motion.y -= 50
		push = 4
		chosen_texture = texture_up
		
		
		
	if Input.is_action_pressed("player2_up") && Input.is_action_pressed("player2_left"):
		chosen_texture = texture_upleft
	if Input.is_action_pressed("player2_up") && Input.is_action_pressed("player2_right"):
		chosen_texture = texture_upright
	if Input.is_action_pressed("player2_down") && Input.is_action_pressed("player2_left"):
		chosen_texture = texture_downleft
	if Input.is_action_pressed("player2_down") && Input.is_action_pressed("player2_right"):
		chosen_texture = texture_downright
		

	if motion != Vector2.ZERO:
		last_direction = motion.normalized()

	if Input.is_action_just_pressed("rect_spawn") and shoot == 0:
		spawn_rectangle()
		shoot = 1  # Prevents multiple rectangles until reset
		

	return motion


func update_player_sprite(texture):
	if $Sprite:
		$Sprite.texture = texture
	else:
		print("Sprite node not found or not ready")
		
		
func move_player(motion: Vector2, delta: float) -> void:
	motion = motion.normalized() * speed * delta
	position += motion
func _on_area_2d_area_entered(area):
	print("pushing me")
		
	if area.is_in_group("inside"):
		queue_free()
		
	if area.is_in_group("block"):
		if push2 == 1:
			position += Vector2(50, 0)
			
		if push2 == 2:
			position += Vector2(-50, 0)
			
		if push2 == 3:
			position += Vector2(0, 50)
			
		if push2 == 4:
			position += Vector2(0, -50)
			
			
func check_arena_bounds() -> void:
	var arena_node = get_parent().get_node("Arena") as Sprite2D
	if arena_node and arena_node.texture:
		var arena_size = arena_node.texture.get_size()
		if position.x < 0 or position.x > arena_size.x or position.y < 0 or position.y > arena_size.y:
			queue_free()  # Remove the player from the scene if they fall off

func spawn_rectangle() -> void:
	if spawned_rectangle != null:
		return

	var rectangle_scene = load(rectangle_scene_path)
	if rectangle_scene is PackedScene:
		spawned_rectangle = rectangle_scene.instantiate() as Node2D
		var sprite_node = spawned_rectangle.get_node("Sprite") as Sprite2D
		sprite_node.texture = chosen_texture  # Apply the texture based on the last direction
		spawned_rectangle.position = position + last_direction * 100
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
			spawned_rectangle.position = position + Vector2(0, 70) + last_direction * 250  # Left movement
		elif last_direction.x > 0:
			spawned_rectangle.position = position + Vector2(0, 70) + last_direction * 400  # Right movement
		elif last_direction.y > 0:  # Up or down
			spawned_rectangle.position = position + Vector2(75, 0) + last_direction * 400  # Slightly to the right
		elif last_direction.y < 0:  # Up or down
			spawned_rectangle.position = position + Vector2(75, 0) + last_direction * 400  # Slightly to the right
			
		
		var sprite_node = spawned_rectangle.get_node("Sprite") as Sprite2D
		sprite_node.texture = chosen_texture
		

func _on_timer_timeout():
	if spawned_rectangle:
		spawned_rectangle.queue_free()
		spawned_rectangle = null
		shoot = 0  # Allow new rectangle to be spawned

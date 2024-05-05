extends RigidBody2D
@export var rectangle_scene2_path: String = "res://Rectangle.tscn"




@export var speed: float = 200  # Speed of the player in pixels per second.
@export var rectangle_scene2 = preload("res://Rectangle.tscn")  # Path to the rectangle scene.
var last_direction2 = Vector2.ZERO  # Variable to store the last direction
var spawned_rectangle2 = null  # Store the rectangle instance

@export var last_direction: String = "res://Player2.tscn"
@export var push: String = "res://Player2.tscn"

var push2 = Player2.push
var push1 = 0
var shoot = 0


# Preload textures for each direction
var texture_right = preload("res://right.png")
var texture_left = preload("res://left.png")
var texture_pright = preload("res://pright.png")
var texture_pleft = preload("res://pleft.png")
var texture_up = preload("res://up.png")
var texture_down = preload("res://down.png")
var chosen_texture = null  # Variable to hold the chosen texture based on direction
var player_sprite = preload("res://player.tscn")  # Assuming this is your player sprite


		
		
func _process(delta: float) -> void:
	var motion2: Vector2 = Vector2()
	motion2 = handle_input(motion2)  # Get the updated motion2 vector
	move_player(motion2, delta)
	if spawned_rectangle2:
		update_rectangle_position()
	
func handle_input(motion2: Vector2) -> Vector2:
	
	push2 = Player2.push
	if Input.is_action_pressed("ui_right"):
		motion2.x += 50
		push1 = 1
		chosen_texture = texture_right
		update_player_sprite(texture_pright)
	if Input.is_action_pressed("ui_left"):
		motion2.x -= 50
		push1 = 2
		chosen_texture = texture_left
		update_player_sprite(texture_pleft)
	if Input.is_action_pressed("ui_down"):
		motion2.y += 50
		push1 = 3
		chosen_texture = texture_down
		
	if Input.is_action_pressed("ui_up"):
		motion2.y -= 50
		push1 = 4
		chosen_texture = texture_up

	if motion2 != Vector2.ZERO:
		last_direction2 = motion2.normalized()

	if Input.is_action_just_pressed("rect_spawn2") && shoot == 0:
		spawn_rectangle2()
		shoot = 1

	return motion2
	
	
func update_player_sprite(texture):
	if $Sprite:
		$Sprite.texture = texture
	else:
		print("Sprite node not found or not ready")



func spawn_rectangle2() -> void:
	if spawned_rectangle2 != null:
		return

	var rectangle_scene2 = load(rectangle_scene2_path)
	if rectangle_scene2 is PackedScene:
		spawned_rectangle2 = rectangle_scene2.instantiate() as Node2D
		var sprite_node2 = spawned_rectangle2.get_node("Sprite") as Sprite2D
		sprite_node2.texture = chosen_texture  # Apply the texture based on the last direction
		spawned_rectangle2.position = position + last_direction2 * 100
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
			spawned_rectangle2.position = position + Vector2(0, 70) + last_direction2 * 250  # Left movement
		elif last_direction2.x > 0:
			spawned_rectangle2.position = position + Vector2(0, 70) + last_direction2 * 400  # Right movement
		elif last_direction2.y > 0:  # Up or down
			spawned_rectangle2.position = position + Vector2(75, 0) + last_direction2 * 400  # Slightly to the right
		elif last_direction2.y < 0:  # Up or down
			spawned_rectangle2.position = position + Vector2(75, 0) + last_direction2 * 400  # Slightly to the right
			
		
		var sprite_node2 = spawned_rectangle2.get_node("Sprite") as Sprite2D
		sprite_node2.texture = chosen_texture

func _on_timer_timeout():
	if spawned_rectangle2:
		spawned_rectangle2.queue_free()
		spawned_rectangle2 = null
		shoot = 1

	
func move_player(motion2: Vector2, delta: float) -> void:
	motion2 = motion2.normalized() * speed * delta
	position += motion2

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
			queue_free()
			
			
			



			
		




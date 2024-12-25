extends Node

var player: RigidBody2D

# Player movement variables
var speed := 100.0  # Movement speed (pixels per second)
var acceleration := 80000.0
var jump_force := -200.0
var free_jump := true
var free_jump_timeout := 0.4
# Input variables
var move_input := 0.0  # Movement direction (1 = right, -1 = left)

func set_player(value: RigidBody2D) -> void:
	player = value
	
func apply_state(delta: float, mouse_position: Vector2) -> void:
	# Get input for left and right movement
	move_input = 0
	if Input.is_action_pressed("move_right"):
		move_input = 1
	elif Input.is_action_pressed("move_left"):
		move_input = -1
	
	if Input.is_action_just_pressed("jump"):
		jump()
	
	# Apply horizontal movement using forces
	apply_horizontal_movement(delta)
	
func cleanup_state() -> void:
	pass

func apply_horizontal_movement(delta: float):
	if is_touching_something() && player.linear_velocity.x < speed && move_input != 0:
		player.apply_force(Vector2(acceleration * delta * move_input, -300))
	else:
		player.apply_force(Vector2(acceleration/10 * delta * -player.linear_velocity.normalized().x, 100))

	

func jump() -> void:
	if free_jump || is_touching_something():
		player.apply_central_impulse(Vector2(0, jump_force))
		if free_jump:
			free_jump = false
			await get_tree().create_timer(free_jump_timeout).timeout
			free_jump = true
		
		

func is_touching_something() -> bool:
	# Check for collisions below the character
	return player.get_contact_count() > 0

extends Camera2D

# Speed of the camera's movement (higher = faster)
var follow_speed = 1.0
var dead_zone_margin = 500

func _ready():
	limit_left = 0
	limit_right = 2000
	limit_top = 0
	limit_bottom = 500
	
	
func _process(delta: float):
	# Get the global position of the mouse
	var mouse_position = get_global_mouse_position()
	
	# Interpolate the camera's position toward the mouse position
	var current_position = global_position
	var target_position = mouse_position
	
	
	var distance = global_position.distance_to(mouse_position)
	var dynamic_speed = distance / 500.0  # Scale speed based on distance
	global_position = current_position.lerp(mouse_position, dynamic_speed * delta)

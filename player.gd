extends RigidBody2D

signal check_polygons(array: PackedVector2Array)

@onready var movement := $PlayerStates/Movement
@onready var aiming := $PlayerStates/Aiming
@onready var bar := $Control/ProgressBar
var active_state: Node


func _ready() -> void:
	movement.set_player(self)
	aiming.set_player(self)
	aiming.set_power_bar(bar)


func _process(delta: float) -> void:
	if Input.is_action_pressed("right_click"):
		update_active_state(aiming)
	else:
		update_active_state(movement)
	
	if active_state != null && active_state.has_method("apply_state"):
		active_state.apply_state(delta, get_global_mouse_position())

func update_active_state(state: Node) -> void:
	if active_state != state && state != null:
		if active_state != null && active_state.has_method("cleanup_state"):
			active_state.cleanup_state()
		active_state = state

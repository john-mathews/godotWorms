extends Node

var player: RigidBody2D
var progress_bar: ProgressBar
var arrow: Line2D
var spawn_time:= 0.1
var can_spawn:= true
var power:= 50.0
var default_power:= 50.0
var is_charging:= false:
	set(value):
		is_charging = value
		#gauge_visibility = value
var charge_speed:= 1000.0
var max_power := 1100.0
var max_curve:= 10.0

func set_player(value: RigidBody2D) -> void:
	player = value

func set_power_bar(value: ProgressBar) -> void:
	progress_bar = value

func apply_state(delta: float, mouse_position: Vector2) -> void:
	if Input.is_action_pressed("left_click"):
		charge_shot(delta, mouse_position)
		
	if Input.is_action_just_released("left_click"):
		print(power)
		is_charging = false
		if can_spawn:
			spawn_projectile(mouse_position)
		power = default_power
		update_power_bar()
		arrow.queue_free()
			
	handle_arrow(mouse_position)
	
func handle_arrow(mouse_position: Vector2) -> void:
	if arrow == null:
		arrow = Line2D.new()
		arrow.width = 3
		arrow.default_color = Color(0, 1, 0, 1)
		arrow.add_point(Vector2.ZERO, 0)
		#var gradient = Gradient.new()
		#gradient.add_point(0.0, Color(1, 0, 0))  # Green at the start
		##gradient.add_point(1.0, Color(0, 1, 0, 1))  # Red at the end
		#arrow.gradient = gradient
		var curve = Curve.new()
		curve.add_point(Vector2(0, 1))  # At start (0.0), width is 3
		curve.bake()  # Smooth out the curve
		arrow.width_curve = curve
		player.add_child(arrow)
	var direction = (mouse_position - player.global_position).normalized()
	if arrow.get_point_count() > 1:
		arrow.remove_point(1)
		arrow.width_curve.remove_point(1)
	var length = clampf(power/max_power * 200, 20, 200)
	var end_curve = clampf(power/max_power * max_curve, 3, max_curve)
	arrow.add_point(direction * length, 1)
	arrow.width_curve.add_point(Vector2(1, end_curve))

	
func charge_shot(delta: float, mouse_position: Vector2) -> void:
	is_charging = true
	if power < max_power:
		power += charge_speed * delta
	else: 
		power = max_power
	update_power_bar()
	
func update_power_bar() -> void:
	progress_bar.value = power/max_power * 100

func spawn_projectile(mouse_position: Vector2) -> void:
	var circle = PolygonHelper.generate_circle_poly(10,10, Vector2.ZERO)
	can_spawn = false
	var rigid_poly = Polygon2D.new()
	rigid_poly.color = Color(randf(),randf(),randf(),1)
	rigid_poly.polygon = circle
	
	var rigid_collision_poly = CollisionPolygon2D.new()
	rigid_collision_poly.polygon = circle
	
	var notifier_inst = VisibleOnScreenNotifier2D.new()
	notifier_inst.connect("screen_exited", _on_screen_exited)
	
	var rigid_inst = RigidBody2D.new()
	rigid_inst.add_child(rigid_collision_poly)
	rigid_inst.add_child(rigid_poly)
	rigid_inst.add_child(notifier_inst)
	rigid_inst.connect("body_entered", _on_body_entered_rigid, CONNECT_ONE_SHOT)
	rigid_inst.contact_monitor = true
	rigid_inst.max_contacts_reported = 1
	rigid_inst.collision_layer = 2
	rigid_inst.set_collision_mask_value(1, true)
	rigid_inst.set_collision_mask_value(3, true)
	var direction = (mouse_position - player.global_position).normalized()
	rigid_inst.position += direction * 30
	player.add_child(rigid_inst)
	add_projectile_force(rigid_inst, direction)
	
func add_projectile_force(projectile: RigidBody2D, direction: Vector2) -> void:
	projectile.apply_central_impulse(direction * power)
	await get_tree().create_timer(spawn_time).timeout
	can_spawn = true
			
func _on_body_entered_rigid(body: Node2D) -> void:
	var children = player.get_children()
	var contact_child: RigidBody2D
	for child in children:
		if child is RigidBody2D:
			if child.get_contact_count() > 0:
				contact_child = child
	if contact_child != null:
		var circle = PolygonHelper.generate_circle_poly(60,15, contact_child.global_position)
		player.check_polygons.emit(circle)
		contact_child.queue_free()
		
func _on_screen_exited() -> void:
	var children = get_children()
	var off_screen_child: RigidBody2D
	for child in children:
		if child is RigidBody2D:
			var grand_children = child.get_children()
			for grand_child in grand_children:
				if grand_child is VisibleOnScreenNotifier2D && !grand_child.is_on_screen():
					off_screen_child = child
	if off_screen_child != null:
		off_screen_child.queue_free()

func cleanup_state() -> void:
	can_spawn = true
	power = default_power
	is_charging = false
	arrow.queue_free()

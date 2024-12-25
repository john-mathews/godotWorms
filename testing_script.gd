extends Node2D

signal check_polygons(array: PackedVector2Array)
var slow_interval:= 0.02
var slow_counter:= 0.0
var spawn_time:= 0.1
var can_spawn:= true

func _process(delta: float) -> void:
	if slow_counter >= slow_interval:
		_slow_process()
		slow_counter = 0.0
		
	slow_counter += delta
			
func _slow_process() -> void:
	check_input()

func check_input() -> void:
	var circle = generate_circle_poly(20,15)
	if Input.is_action_pressed("left_click"):
		var inst := Polygon2D.new()
		inst.polygon = circle
		inst.global_position = Vector2.ZERO
		var mouse_pos:= get_global_mouse_position()
		var offset_poly:= offset_polygon_points(inst.polygon, mouse_pos)
		check_polygons.emit(offset_poly)
		inst.polygon = offset_poly
		#add_child(inst)
	if Input.is_action_pressed("right_click"):
		if can_spawn:
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
			rigid_inst.collision_mask = 1
			rigid_inst.global_position = get_global_mouse_position()
			add_child(rigid_inst)
			await get_tree().create_timer(spawn_time).timeout
			can_spawn = true
		#just add timer instead of going off of collision
	
func generate_circle_poly(radius: float, num_sides: int) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array
	for _i in num_sides:
		polygon.append(vector + position)
		vector = vector.rotated(angle_delta)
	return polygon
	
func _on_body_entered_rigid(body: Node2D) -> void:
	var children = get_children()
	var circle = generate_circle_poly(60,15)
	var contact_child: RigidBody2D
	for child in children:
		if child is RigidBody2D:
			if child.get_contact_count() > 0:
				contact_child = child
	if contact_child != null:
		var inst := Polygon2D.new()
		inst.polygon = circle
		inst.global_position = Vector2.ZERO
		var offset_poly:= offset_polygon_points(inst.polygon, contact_child.global_position)
		check_polygons.emit(offset_poly)
		inst.polygon = offset_poly
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
	
func offset_polygon_points(packed_vector2s: PackedVector2Array, offset_position: Vector2) -> PackedVector2Array:
		var offset_poly: PackedVector2Array = []
		for point in packed_vector2s:
			offset_poly.append(point + offset_position)
		return offset_poly

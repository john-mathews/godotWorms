extends Node2D

@onready var tester = $Node2D
@onready var map: LevelMap = $Map
@onready var player = $Player

func _ready() -> void:
	tester.connect("check_polygons", _on_check_polygons)
	player.connect("check_polygons", _on_check_polygons)
	
func _on_check_polygons(polygon: PackedVector2Array):
	#print_debug(polygon)
	var children_to_remove: Array[StaticPolygonBody2D] = []
	for map_polygon in map.static_bodies:
		if map_polygon != null:
			var geometry = Geometry2D.clip_polygons(map_polygon.polygon_points, polygon)
			if geometry.size() == 1:
				map_polygon.polygon_points = geometry[0]
			elif geometry.size() > 1:
				children_to_remove.append(map_polygon)
				for geo in geometry:
					if !Geometry2D.is_polygon_clockwise(geo):
						var new_static_polygon = StaticPolygonBody2D.new()
						new_static_polygon.polygon_points = geo
						map.add_child(new_static_polygon)
			else: 
				children_to_remove.append(map_polygon)
	map.get_static_bodies()
	for child in children_to_remove:
		child.queue_free()

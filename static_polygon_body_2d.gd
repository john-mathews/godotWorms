@tool
class_name StaticPolygonBody2D extends StaticBody2D

@export var polygon_points: PackedVector2Array:
	set(value):
		polygon_points = value
		if value != null:
			setup_polygon()
			
var shape: Polygon2D
var collision: CollisionPolygon2D

func _ready() -> void:
	#eventually we will generate the polygon for both and assign
	#for now just copy collision to match visible polygon
	shape = Polygon2D.new()
	collision = CollisionPolygon2D.new()
	shape.color = Color(randf()+.5, randf()+.2, randf()+.2, 1)
	setup_polygon()
	add_child(shape)
	add_child(collision)

func setup_polygon() -> void:
	if collision != null && shape != null:
		collision.set_deferred("polygon", polygon_points)
		#collision.polygon = polygon_points
		shape.set_deferred("polygon", polygon_points)
		#shape.polygon = polygon_points

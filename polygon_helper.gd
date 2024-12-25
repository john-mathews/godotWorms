class_name PolygonHelper extends Node2D

	
static func offset_polygon_points(packed_vector2s: PackedVector2Array, offset_position: Vector2) -> PackedVector2Array:
	var offset_poly: PackedVector2Array = []
	for point in packed_vector2s:
		offset_poly.append(point + offset_position)
	return offset_poly

static func generate_circle_poly(radius: float, num_sides: int, poly_position: Vector2) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array
	for _i in num_sides:
		polygon.append(vector + poly_position)
		vector = vector.rotated(angle_delta)
	return polygon

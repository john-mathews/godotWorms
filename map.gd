class_name LevelMap extends Node2D

var static_bodies: Array[StaticPolygonBody2D]

func _ready() -> void:
	generate_map_data()
	get_static_bodies()
	
#have a signal that calls this
func get_static_bodies() -> void:
	static_bodies = []
	var children = get_children()
	for child in children:
		if child is StaticPolygonBody2D:
			static_bodies.append(child)

func generate_map_data() -> void:
	var width = 2048
	var height = 512
	var points_count = 200
	var terrain_points = generate_terrain(width, height, points_count, .07)
	var staticPolyBody = StaticPolygonBody2D.new()
	staticPolyBody.polygon_points = terrain_points
	add_child(staticPolyBody)
	
	

func generate_terrain(width: float, height: float, points_count: int, frequency:= 1.0) -> PackedVector2Array:
	var points = []
	var step = width / (points_count - 1)
	print(step)
	
	# Create a noise generator
	var noise = FastNoiseLite.new()
	noise.seed = randi()  # Randomize the seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	# Generate points with noise
	for i in range(points_count):
		var x = i * step
		var base_noise = noise.get_noise_2d(x * frequency, 1) * height * 1.6
		var y = clamp(base_noise + height * 0.6, 1, height - 25)
		points.append(Vector2(x, y))
		
	print(points.map(map_y).max())
	points = remove_duplicate_points(points)
	points = simplify_polygon(points)
	points = smooth(points)
	
	# Close the loop for the polygon
	points.append(Vector2(width, height))  # Bottom-right corner
	points.append(Vector2(0, height))     # Bottom-left corner
	
	return PackedVector2Array(points)

func smooth(points: Array) -> Array:
	# Use linear interpolation to smooth points
	var smoothed = []
	for i in range(points.size() - 1):
		var p1 = points[i]
		var p2 = points[i + 1]
		smoothed.append(p1)  # Keep the original point
		smoothed.append(p1.lerp(p2, 0.5))  # Add midpoint for smoothing
	smoothed.append(points[-1])  # Ensure the last point is included
	return smoothed

func remove_duplicate_points(points: Array) -> Array:
	var cleaned = []
	for p in points:
		if not cleaned or cleaned[-1].distance_to(p) > 1e-5:  # Threshold for duplicates
			cleaned.append(p)
	return cleaned

func simplify_polygon(points: Array) -> Array:
	# Simplify the polygon by removing very close points (this step is optional)
	var simplified = []
	for i in range(points.size()):
		var p1 = points[i]
		var p2 = points[(i + 1) % points.size()]  # Loop back to the start
		if p1.distance_to(p2) > 1.0:  # Merge close points
			simplified.append(p1)
	return simplified

func map_y(point: Vector2) -> float:
	return point.y

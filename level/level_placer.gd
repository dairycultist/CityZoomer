extends StaticBody3D

const ROAD_STRAIGHT = preload("./road/road_segment_straight.tscn")
const ROAD_X = preload("./road/road_segment_x.tscn")
const ROAD_END = preload("./road/road_segment_end.tscn")

var random = RandomNumberGenerator.new()

var x = 0
var z = 0
var direction = 0 # -1, 0, 1

func _ready() -> void:
	
	place_random()

# "PlacementModule" system (have an entrance and an exit, and are guaranteed to
# never intersect with others. maybe check AABB before instantiating?)
func place_random():
	place_curvy_road(20)

func place_curvy_road(length: int):
	
	var road_length = random.randi_range(3, 5)
	
	for i in range(0, length):
		
		# build road
		var road = ROAD_STRAIGHT.instantiate()
		add_child(road)
		road.position = Vector3(x * 16, 0, z * 16)
		road.rotation.y = direction * PI / 2
		
		x += sin(direction * PI / 2)
		z += cos(direction * PI / 2)
		
		road_length -= 1
		
		# change direction
		if road_length == 0:
			
			road_length = random.randi_range(3, 5)
			
			# place intersection
			road = ROAD_X.instantiate()
			add_child(road)
			road.position = Vector3(x * 16, 0, z * 16)
			
			road = ROAD_END.instantiate()
			add_child(road)
			road.position = Vector3((x + sin(direction * PI / 2)) * 16, 0, (z + cos(direction * PI / 2)) * 16)
			road.rotation.y = direction * PI / 2
			
			if direction == 1 or direction == -1:
				direction = 0
			else:
				direction = random.randi_range(0, 1) * 2 - 1
			
			road = ROAD_END.instantiate()
			add_child(road)
			road.position = Vector3((x - sin(direction * PI / 2)) * 16, 0, (z - cos(direction * PI / 2)) * 16)
			road.rotation.y = direction * PI / 2 + PI
			
			x += sin(direction * PI / 2)
			z += cos(direction * PI / 2)

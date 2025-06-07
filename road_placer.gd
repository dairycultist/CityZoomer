extends StaticBody3D

const ROAD_STRAIGHT = preload("res://things/road/road_segment_straight.tscn")
const ROAD_X = preload("res://things/road/road_segment_x.tscn")
const ROAD_END = preload("res://things/road/road_segment_end.tscn")

var random = RandomNumberGenerator.new()

var x = 0
var z = 0
var direction = 0 # -1, 0, 1

func _ready() -> void:
	
	$Checkpoint.body_entered.connect(checkpoint_touched)
	
	generate_road(20)
	
func generate_road(length: int):
	
	var road_length = random.randi_range(3, 5)
	
	for i in range(0, length):
		
		if i == length / 2:
			$Checkpoint.position = Vector3(x * 16, 0, z * 16)
		
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

func checkpoint_touched(area: Node3D):
	
	if area.name == "Player":
		generate_road(20)

extends StaticBody3D

const ROAD_STRAIGHT = preload("res://things/road/road_segment_straight.tscn")
const ROAD_X = preload("res://things/road/road_segment_x.tscn")
const ROAD_END = preload("res://things/road/road_segment_end.tscn")

func _ready() -> void:
	
	$Checkpoint.position = Vector3(0, 0, 8 * 16)
	$Checkpoint.body_entered.connect(_checkpoint_touched)
	
	var random = RandomNumberGenerator.new()
	
	var road_length = random.randi_range(3, 5)
	
	var x = 0
	var z = 0
	var direction = 0 # -1, 0, 1
	
	for i in range(0, 32):
		
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
			
			# place intersection
			road = ROAD_X.instantiate()
			add_child(road)
			road.position = Vector3(x * 16, 0, z * 16)
			
			road_length = random.randi_range(3, 5)
			
			if direction == 1 or direction == -1:
				direction = 0
			else:
				direction = random.randi_range(0, 1) * 2 - 1
			
			x += sin(direction * PI / 2)
			z += cos(direction * PI / 2)

func _checkpoint_touched(_area: Node3D):
		
	# remember to check that it is the player entering and not something else
	print("test")

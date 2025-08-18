extends StaticBody3D

@export var rooms: Array[PackedScene]
@export var door_stopper: PackedScene

var random = RandomNumberGenerator.new()

func _ready() -> void:
	
	# TODO handle spawn room differently since it isn't placed off of a door
	place_random_room(Node3D.new(), 2)

# rooms have children in group "Door" for connecting together (Z+ is outwards)
func get_doors(room: Node3D) -> Array[Node3D]:
	
	var doors: Array[Node3D] = []
	
	for child in room.get_children():
		if child.is_in_group("Door"):
			doors.append(child)
	
	return doors

func place_door_stopper(door: Node3D) -> void:
	
	var stopper = door_stopper.instantiate()
	add_child(stopper)
	stopper.global_position = door.global_position
	stopper.global_rotation = door.global_rotation

func place_random_room(from_door: Node3D, max_depth: int) -> void:
	
	# TODO select a random door, then use my_collider.get_aabb()
	# to ensure no intersections
	
	if (max_depth <= 0):
		# place door stopper on top of door (doesn't check AABB)
		place_door_stopper(from_door)
		return
	
	# place the room such that it is connected with the door
	var room = rooms[random.randi() % rooms.size()].instantiate()
	add_child(room)
	
	var doors := get_doors(room)
	var to_door: Node3D = doors.pop_back()
	
	room.global_rotation.y = from_door.global_rotation.y - to_door.global_rotation.y + PI
	room.global_position = from_door.global_position - (to_door.position.rotated(Vector3.UP, room.rotation.y))
	
	# place rooms at all other doors
	# 	right now just connects a random possible room to a room (a room
	# 	cannot specify which rooms are allowed to be placed next to it)
	while not doors.is_empty():
		place_random_room(
			doors.pop_back(),
			max_depth - 1
		)

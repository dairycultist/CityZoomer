extends StaticBody3D

@export var rooms: Array[PackedScene]
@export var door_stopper: PackedScene

var random = RandomNumberGenerator.new()

func _ready() -> void:
	place_room(rooms[0], Node3D.new(), 3)

# rooms have children in group "Door" for connecting together (Z+ is outwards)
func get_doors(room: Node3D) -> Array[Node3D]:
	
	var doors: Array[Node3D] = []
	
	for child in room.get_children():
		if child.is_in_group("Door"):
			doors.append(child)
	
	return doors

# returns true if succeeded in placing a room, false otherwise
func place_room(room_prefab: PackedScene, from_door: Node3D, max_depth: int) -> bool:
	
	# TODO my_collider.get_aabb() to ensure they don't intersect
	
	if (max_depth <= 0):
		## place door stopper on top of door (doesn't check AABB)
		#var stopper = door_stopper.instantiate()
		#add_child(stopper)
		#stopper.global_position = from_door.global_position
		#stopper.global_position = from_door.global_rotation
		return true
	
	# place the room such that it is connected with the door
	var room = room_prefab.instantiate()
	add_child(room)
	
	var doors := get_doors(room)
	var to_door: Node3D = doors.pop_back()
	
	room.global_rotation.y = from_door.global_rotation.y - to_door.global_rotation.y + PI
	room.global_position = from_door.global_position - (to_door.position.rotated(Vector3.UP, room.rotation.y))
	
	# place rooms at all other doors
	# 	right now just connects a random possible room to a room (a room
	# 	cannot specify which rooms are allowed to be placed next to it)
	while not doors.is_empty():
		place_room(
			rooms[1], # random.randi() % rooms.size()
			doors.pop_back(),
			max_depth - 1
		)
	
	return true

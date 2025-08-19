extends StaticBody3D

@export var max_depth: int = 5
@export var spawn_room: PackedScene
@export var rooms: Array[PackedScene]
@export var door_stopper: PackedScene

var random = RandomNumberGenerator.new()

func _ready() -> void:
	
	# must handle spawn room differently since it isn't placed off of a door
	var room: Node3D = spawn_room.instantiate()
	add_child(room)
	
	var doors := get_doors(room)
	doors.shuffle()
	
	# start branching off doors
	while not doors.is_empty():
		place_random_room(
			doors.pop_back(),
			max_depth
		)

# rooms have children in group "Door" for connecting together (Z+ is outwards)
func get_doors(room: Node3D) -> Array[Node3D]:
	
	var doors: Array[Node3D] = []
	
	for child in room.get_children():
		if child.is_in_group("Door"):
			doors.append(child)
	
	return doors

# place door stopper on top of door (doesn't check AABB)
func place_door_stopper(door: Node3D) -> void:
	
	if not door_stopper:
		return
	
	var stopper = door_stopper.instantiate()
	add_child(stopper)
	stopper.global_position = door.global_position
	stopper.global_rotation = door.global_rotation

# gets AABB in global space
# (only of ROOM'S collider, no need to include that from objects within)
func get_room_aabb(room: Node3D) -> AABB:
	
	var shape = room.shape as ConcavePolygonShape3D
	var aabb = AABB()
	for face in shape.get_faces():
		aabb = aabb.expand(face.rotated(Vector3.UP, room.rotation.y))
	
	aabb.position += room.position
	
	return aabb

func room_causes_intersection(room: Node3D) -> bool:
	
	# get room's bounding box (shrunken slightly due to precision)
	var aabb := get_room_aabb(room)
	
	aabb.size -= Vector3(0.2, 0.2, 0.2)
	aabb.position += Vector3(0.1, 0.1, 0.1)
	
	# compare against all other rooms
	for other_room in get_children():
		
		if room != other_room:
			if aabb.intersects(get_room_aabb(other_room)):
				return true
	
	return false

# TODO instead of immediately placing the room, queue it to
# prevent one path from completely dominating and then preventing
# the placement of other paths

func place_random_room(from_door: Node3D, max_depth: int) -> void:
	
	if (max_depth <= 0):
		place_door_stopper(from_door)
		return
	
	# attempt to place a random room
	var room_pool := rooms.duplicate()
	room_pool.shuffle()
	
	while not room_pool.is_empty():
	
		# place the room such that it is connected with from_door
		var room: Node3D = room_pool.pop_back().instantiate()
		add_child(room)
		
		var doors := get_doors(room)
		doors.shuffle()
		var to_door: Node3D = doors.pop_back()
		
		room.global_rotation.y = from_door.global_rotation.y - to_door.global_rotation.y + PI
		room.global_position = from_door.global_position - (to_door.position.rotated(Vector3.UP, room.rotation.y))
		
		# if intersecting with other rooms, delete and try again
		# (room root node should be its collider)
		if (room_causes_intersection(room)):
			
			remove_child(room)
			room.queue_free()
			
		else:
			# otherwise, place rooms at all open doors of this room
			# 	right now just connects a random possible room to a room (a room
			# 	cannot specify which rooms are allowed to be placed next to it)
			while not doors.is_empty():
				place_random_room(
					doors.pop_back(),
					max_depth - 1
				)
			return
	
	# if there are no more possible rooms, place a door stopper
	place_door_stopper(from_door)

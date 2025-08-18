extends StaticBody3D

@export var connector_rooms: Array[PackedScene]
@export var dead_end_rooms: Array[PackedScene]

var random = RandomNumberGenerator.new()

func _ready() -> void:
	
	place_room(connector_rooms[0], Transform3D(Basis(), Vector3.ZERO))

# rooms have children in group "Door" for connecting together (Z+ is outwards)

# TODO my_collider.get_aabb() to ensure they don't intersect

func place_room(room: PackedScene, door: Transform3D) -> void:
	
	# place the room such that it is connected with the door
	var t = room.instantiate()
	add_child(t)
	t.position = Vector3(0, 0, 0)
	
	# place rooms at all other doors
	# 	right now just connects a random possible room to a room (a room
	# 	cannot specify which rooms are allowed to be placed next to it)

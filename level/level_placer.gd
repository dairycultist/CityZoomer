extends StaticBody3D

@export var connector_rooms: Array[PackedScene]
@export var dead_end_rooms: Array[PackedScene]

var random = RandomNumberGenerator.new()

func _ready() -> void:
	
	place_room(connector_rooms[0], Node3D.new())

# rooms have children in group "Door" for connecting together (Z+ is outwards)
func get_doors(room: Node3D) -> Array[Node3D]:
	
	var doors: Array[Node3D] = []
	
	for child in room.get_children():
		
		if child.is_in_group("Door"):
			doors.append(child)
	
	return doors

# TODO my_collider.get_aabb() to ensure they don't intersect

func place_room(room_prefab: PackedScene, door: Node3D) -> void:
	
	# place the room such that it is connected with the door
	var room = room_prefab.instantiate()
	add_child(room)
	room.position = door.global_position - get_doors(room)[0].position
	
	# place rooms at all other doors
	# 	right now just connects a random possible room to a room (a room
	# 	cannot specify which rooms are allowed to be placed next to it)

extends StaticBody3D

# have empty Node3Ds in group "Door" for connecting together with
# Z+ arrow (BLUE) pointing out of the door

# my_collider.get_aabb() to ensure they don't intersect

# right now just connects a random possible room to a room (a room cannot
# specify which rooms are allowed to be placed next to it)
@export var connector_rooms: Array[PackedScene]
@export var dead_end_rooms: Array[PackedScene]

var random = RandomNumberGenerator.new()

func _ready() -> void:
	
	place_room(connector_rooms[0])

func place_room(room: PackedScene) -> void:
	
	var t = room.instantiate()
			
	add_child(t)
	t.position = Vector3(0, 0, 0)

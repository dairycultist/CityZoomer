extends MeshInstance3D

@export var player_camera : Node3D
@export var target : Node3D

func _process(_delta: float) -> void:
	
	look_at_from_position(target.global_position, player_camera.global_position)
	position = Vector3(0, 0, -2)
	rotation.y -= player_camera.global_rotation.y
	rotation.x += player_camera.global_rotation.x

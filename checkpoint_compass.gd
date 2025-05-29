extends MeshInstance3D

@onready var player_camera: Node3D = $"/root/GameScene/Player/Camera3D"
@onready var checkpoint: Node3D = $"/root/GameScene/Checkpoint"

func _process(_delta: float) -> void:
	
	look_at_from_position(checkpoint.global_position, player_camera.global_position)
	position = Vector3(0, 0, -2)
	rotation.y -= player_camera.global_rotation.y
	rotation.x += player_camera.global_rotation.x

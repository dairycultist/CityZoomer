extends MeshInstance3D

@onready var player: Node3D = $"/root/GameScene/Player"

func _process(delta: float) -> void:
	
	if (player.global_position.y < global_position.y):
		player.global_position = Vector3.ZERO
		player.velocity = Vector3.ZERO
	
	global_position.x = player.global_position.x
	global_position.z = player.global_position.z
	
	self.mesh.surface_get_material(0).set("shader_parameter/player_dist", player.global_position.y - global_position.y);
	
	pass

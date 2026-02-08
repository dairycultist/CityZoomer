extends Player

#if the agent sees the player, either shoot or move to a position where the agent can't see the player
@onready var agent := $NavigationAgent3D

@export var target: Node3D
	
func _physics_process(delta: float) -> void:
	
	agent.target_position = target.global_position
	
	if global_position.distance_to(target.global_position) > 3.0:

		var next_pos_raw = agent.get_next_path_position()
		var next_pos = Vector3(next_pos_raw.x, 0.0, next_pos_raw.z)
		var curr_pos = Vector3(global_position.x, 0.0, global_position.z)

		_process_move((next_pos - curr_pos).normalized(), false, delta)
	
	else:
		
		_process_move(Vector3.ZERO, false, delta)

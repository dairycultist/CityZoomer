extends Player

@export var target: Node3D
	
func _physics_process(delta: float) -> void:
	
	# if the agent can see the player, move to a
	# position where the agent can't see the player
	# (by looping through a list of hiding-spot nodes until
	# it find one that the player can't see)
	
	# TODO: offensive behaviour like scouting for the player's position
	# (to store in memory), shooting when seeing the player, etc
	
	# TODO: have "sight" be based on both seeing stuff in front of the agent,
	# as well as being hit by a bullet
	
	_look_at(target)
	
	$NavigationAgent3D.target_position = target.global_position
	
	if global_position.distance_to(target.global_position) > 3.0:

		var next_pos_raw = $NavigationAgent3D.get_next_path_position()
		var next_pos = Vector3(next_pos_raw.x, 0.0, next_pos_raw.z)
		var curr_pos = Vector3(global_position.x, 0.0, global_position.z)

		_process_move((next_pos - curr_pos).normalized(), false, delta)
	
	else:
		
		_process_move(Vector3.ZERO, false, delta)

extends Player

# state machine w/ two states, Offensive and Defensive, which they
# switch between based on reloading, health, match time, etc

# in Defensive, they try to hide behind cover based on where they
# think you are, but will still shoot at you if they see you (as
# they run to cover)

# in Offensive, they'll try to find you based on where they think
# you are (and scout you out if they learn you're not where they
# thought you'd be), moving out of cover but not out into the open,
# just enough to spot you and open fire

# where they "think you are" is based off a sight system that takes
# into account seeing stuff in front of the agent, being hit by a
# bullet, hearing other players, etc

@export var target: Node3D
	
func _physics_process(delta: float) -> void:
	
	# if the agent can see the player, move to a
	# position where the agent can't see the player
	# (by looping through a list of hiding-spot nodes until
	# it find one that the player can't see)
	
	$NavigationAgent3D.target_position = target.global_position
	
	if global_position.distance_to(target.global_position) > 3.0:

		var next_pos_raw = $NavigationAgent3D.get_next_path_position()
		var next_pos = Vector3(next_pos_raw.x, 0.0, next_pos_raw.z)
		var curr_pos = Vector3(global_position.x, 0.0, global_position.z)

		_process_move((next_pos - curr_pos).normalized(), false, delta)
		_look_towards_move()
	
	else:
		
		_process_move(Vector3.ZERO, false, delta)
		_look_at(target)

extends Player

# in Offensive, they'll try to find you based on where they think
# you are (and scout you out if they learn you're not where they
# thought you'd be), moving out of cover but not out into the open,
# just enough to spot you and open fire

# where they "think you are" is based off a sight system that takes
# into account seeing stuff in front of the agent, being hit by a
# bullet, hearing other players, etc

@export var hiding_spot_parent: Node3D

@export var foes: Array[Player]
@export var state: State

# switch between based on reloading, health, match time, etc
enum State {
	Defensive,
	Offensive
}

func select_hiding_spot():
	
	var hiding_spots := hiding_spot_parent.get_children().duplicate()
	
	# sort hiding spots nearest to furthest from bot player
	hiding_spots.sort_custom(func(a, b):
		return a.global_position.distance_squared_to(self.global_position) < b.global_position.distance_squared_to(self.global_position)
	)
	
	# the currently selected hiding spot has this amount of foes visible
	# at it
	var best_amt = 100
	
	# select nearest hiding spot where we can't see TODO any foe
	for i in range(hiding_spots.size()):
		
		# raycast from the hiding spot to the foe
		var query = PhysicsRayQueryParameters3D.create(
			hiding_spots[i].global_position + Vector3.UP,
			foes[0].global_position + Vector3.UP
		)
		
		query.exclude = [self, foes[0]]
		
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		var amt = 0 if result else 1
		
		if amt < best_amt:
			$NavigationAgent3D.target_position = hiding_spots[i].global_position
			best_amt = amt

func _physics_process(delta: float) -> void:
	
	# Defensive:
	
	# if the agent can see the player, move to a
	# position where the agent can't see the player
	# (by looping through a list of hiding-spot nodes until
	# it find one that the player can't see)
	
	select_hiding_spot()
	
	# logic shared between Defensive and Offensive
	# for running and shooting
	var next_pos_raw = $NavigationAgent3D.get_next_path_position()
	var next_pos = Vector3(next_pos_raw.x, 0.0, next_pos_raw.z)
	var curr_pos = Vector3(global_position.x, 0.0, global_position.z)
	var diff = next_pos - curr_pos
	
	if diff.length() > 0.5:

		_process_move(diff.normalized(), false, delta)
		_look_towards_move()
	
	else:
		
		_process_move(Vector3.ZERO, false, delta)
		#_look_at(target)
	
	# TODO the agent will still shoot at you if they see you
	# (as they run to cover)

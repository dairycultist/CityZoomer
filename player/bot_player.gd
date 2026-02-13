extends Player

# in Offensive, they'll try to find you based on where they think
# you are (and scout you out if they learn you're not where they
# thought you'd be), moving out of cover but not out into the open,
# just enough to spot you, stand still, and open fire

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

func point_can_see_foe(global_point: Vector3, foe_index: int) -> bool:
	
	var query = PhysicsRayQueryParameters3D.create(
		global_point,
		foes[foe_index].global_position + Vector3.UP
	)
	
	query.exclude = [self, foes[foe_index]]
	
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func select_hiding_spot():
	
	var hiding_spots := hiding_spot_parent.get_children().duplicate()
	
	# sort hiding spots nearest to furthest from bot player
	hiding_spots.sort_custom(func(a, b):
		return a.global_position.distance_squared_to(self.global_position) < b.global_position.distance_squared_to(self.global_position)
	)
	
	# the currently selected hiding spot has this amount of foes visible
	# at it
	var best_amt = 100
	
	# select nearest hiding spot where we can't see any foe
	for hiding_spot in hiding_spots:
		
		var amt = 0
		
		for i in range(foes.size()):
			if point_can_see_foe(hiding_spot.global_position + Vector3.UP, i):
				amt += 1
		
		if amt < best_amt:
			$NavigationAgent3D.target_position = hiding_spot.global_position
			best_amt = amt

func _physics_process(delta: float) -> void:
	
	if state == State.Defensive:
		
		# Defensive: go to nearest hiding spot where we see the fewest
		# number of foes
		select_hiding_spot()
		
		#if $NavigationAgent3D.distance_to_target() > 10.0:
			## can't run to cover fast enough, switch to Offensive
			#state = State.Offensive
		
	else:
		pass
	
	# logic shared between Defensive and Offensive
	# for running and shooting
	var target_foe = -1
	
	if point_can_see_foe($CameraAnchor.global_position, 0):
		target_foe = 0
	
	var next_pos_raw = $NavigationAgent3D.get_next_path_position()
	var next_pos = Vector3(next_pos_raw.x, 0.0, next_pos_raw.z)
	var curr_pos = Vector3(global_position.x, 0.0, global_position.z)
	var diff = next_pos - curr_pos
	
	if diff.length() > 0.5:

		_process_move(diff.normalized(), false, delta)
		if target_foe == -1:
			_look_towards_move(delta)
	
	else:
		
		_process_move(Vector3.ZERO, false, delta)
		#_look_at(target)
	
	# TODO the agent will always shoot at you (after a reaction-time
	# delay) once they see you (whether they're running to cover or
	# intentionally camping you)
	if target_foe != -1:
		_look_at(foes[target_foe], delta)
		_shoot()

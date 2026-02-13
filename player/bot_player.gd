class_name BotPlayer
extends Player

# in Offensive, go to nearest hiding spot with foes suspected to be
# there (if the bot has no idea where any foe is, move randomly)
# AS SOON AS they spot a foe, they will stand still and open fire
# (as to not move into the open, just out of cover)

# where they "think you are" is based off a sight system that takes
# into account seeing stuff in front of the agent, being hit by a
# bullet, hearing other players, etc
# the suspected position of each foe is initialized with their spawnpoint

@export var hiding_spot_parent: Node3D

@export var friends: Array[Player]
@export var foes: Array[Player]
@export var state: State

# switch between based on reloading, health, match time, etc
enum State {
	Defensive,
	Offensive
}

# uses the foe's suspected position based on previous information
func can_see_suspected_foe(foe_index: int) -> bool:
	return point_can_see_suspected_foe($CameraAnchor.global_position, foe_index)
	
func point_can_see_suspected_foe(global_point: Vector3, foe_index: int) -> bool:
	
	# TODO make partial knowledge
	
	var query = PhysicsRayQueryParameters3D.create(
		global_point,
		foes[foe_index].global_position + Vector3.UP
	)
	
	query.collision_mask = 1 # terrain is layer 1, players are layer 2
	
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

# uses the foe's true position
func can_see_foe(foe_index: int) -> bool:
	return point_can_see_foe($CameraAnchor.global_position, foe_index)
	
func point_can_see_foe(global_point: Vector3, foe_index: int) -> bool:
	
	var query = PhysicsRayQueryParameters3D.create(
		global_point,
		foes[foe_index].global_position + Vector3.UP
	)
	
	query.collision_mask = 1 # terrain is layer 1, players are layer 2
	
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func select_hiding_spot():
	
	var hiding_spots := hiding_spot_parent.get_children().duplicate()
	
	# sort hiding spots nearest to furthest from bot player
	hiding_spots.sort_custom(func(a, b):
		return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)
	)
	
	# the currently selected hiding spot has this amount of foes visible at it
	var best_amt = 100
	
	# select nearest hiding spot where we can't see any foe
	for hiding_spot in hiding_spots:
		
		# if one of your BOT friends is closer to this spot than you are, and
		# they are in the Defense state, ignore this spot (to prevent crowding)
		var skip_this_spot := false
		
		for i in range(friends.size()):
			if friends[i] is BotPlayer and friends[i].state == State.Defensive and friends[i].global_position.distance_squared_to(hiding_spot.global_position) < global_position.distance_squared_to(hiding_spot.global_position):
				skip_this_spot = true
				break
		
		if skip_this_spot:
			continue
		
		# otherwise, count how many foes can be seen from this spot
		var amt = 0
		
		for i in range(foes.size()):
			if point_can_see_suspected_foe(hiding_spot.global_position + Vector3.UP, i):
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
			## can't reach cover fast enough, switch to Offensive
			#state = State.Offensive
		
	else:
		pass
	
	# logic shared between Defensive and Offensive
	
	# update belief of foe positions (this is the ONLY place where the actual
	# foe position is/should be used!)
	for i in range(foes.size()):
		
		if can_see_foe(i):
			
			# TODO if above zero, decrement reaction timer by delta;
			#      otherwise, update the suspected foe position
			pass
		
		else:
			
			# TODO reset reaction timer
			
			if can_see_suspected_foe(i):
			
				# TODO we suspect the foe to be somewhere they aren't,
				#      toss out belief about where foe is suspected to be
				pass
	
	# get a targeted foe if possible
	var target_foe = -1
	
	if can_see_suspected_foe(0): # suspected, to account for reaction time and prefiring
		target_foe = 0
	
	# running
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
	
	# TODO shoot at the target (regardless of if running to cover or being aggressive)
	if target_foe != -1:
		_look_at(foes[target_foe], delta) # TODO should be suspected position
		_shoot()

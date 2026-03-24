extends Node

@export_group("Maze Size")
@export var MAZE_WIDTH = 6
@export var MAZE_LENGTH = 4

const ROOM = preload("res://mazegen/room.tscn")
const PATH = preload("res://mazegen/path.tscn")
const WALL = preload("res://mazegen/wall.tscn")

const ROOM_DIMENSIONS : float = 5

func _ready() -> void:
	
	var maze_data = []
	
	for w in range(0, MAZE_WIDTH):
		
		maze_data.append([])
		
		for l in range(0, MAZE_LENGTH):
			
			maze_data[w].append([])
			
			var room := ROOM.instantiate()
			add_child(room)
			room.position = Vector3(w * ROOM_DIMENSIONS, 0, l * ROOM_DIMENSIONS)
	
	# generaze maze array with randomized depth-first search
	var stack = [ Vector2i(0, 0) ]
	var visited = [ Vector2i(0, 0) ]
	
	while not stack.is_empty():
		
		var current = stack.back()
		
		var possible_directions = []
		
		if current.x - 1 >= 0 and not visited.has(current + Vector2i(-1, 0)):
			possible_directions.append(0) # -x
			
		if current.y + 1 < MAZE_LENGTH and not visited.has(current + Vector2i(0, 1)):
			possible_directions.append(1) # +y
			
		if current.x + 1 < MAZE_WIDTH and not visited.has(current + Vector2i(1, 0)):
			possible_directions.append(2) # +x
			
		if current.y - 1 >= 0 and not visited.has(current + Vector2i(0, -1)):
			possible_directions.append(3) # -y
		
		# push a random neighbor that hasn't already been built
		# if you can't, pop
		if possible_directions.is_empty():
			stack.pop_back()
		else:
			var chosen_direction = possible_directions.pick_random()
			var new_position = current + dir_index_to_vec2(chosen_direction)
			
			stack.push_back(new_position)
			visited.push_back(new_position)
			
			maze_data[current.x][current.y].append(chosen_direction)
	
	# generate mesh from maze array
	for w in range(0, MAZE_WIDTH):
		for l in range(0, MAZE_LENGTH):
			for dir_index in range(0, 4):
				
				var dir := dir_index_to_vec3(dir_index)
				var wall_position = (Vector3i(w, 0, l) * 2 + dir) * ROOM_DIMENSIONS / 2
				
				if maze_data[w][l].has(dir_index):
				
					# path
					var path := PATH.instantiate()
					add_child(path)
					path.position = wall_position
					path.rotation = Vector3(0, dir_index * PI / 2, 0)
					
				elif not within_maze_bounds(w + dir.x, l + dir.z) or not maze_data[w + dir.x][l + dir.z].has((dir_index + 2) % 4):
					
					# wall (only if other side doesn't have path)
					var wall := WALL.instantiate()
					add_child(wall)
					wall.position = wall_position
					wall.rotation = Vector3(0, dir_index * PI / 2, 0)

func within_maze_bounds(x: int, z: int) -> bool:
	
	return x >= 0 and z >= 0 and x < MAZE_WIDTH and z < MAZE_LENGTH

func dir_index_to_vec2(dir: int) -> Vector2i:
	
	match dir:
		0: return Vector2i(-1, 0)
		1: return Vector2i(0, 1)
		2: return Vector2i(1, 0)
		_: return Vector2i(0, -1)

func dir_index_to_vec3(dir: int) -> Vector3i:
	
	match dir:
		0: return Vector3i(-1, 0, 0)
		1: return Vector3i(0, 0, 1)
		2: return Vector3i(1, 0, 0)
		_: return Vector3i(0, 0, -1)

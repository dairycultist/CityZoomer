extends CharacterBody3D

@export var mouse_sensitivity := 0.3
var camera_pitch := 0.0

@export_group("Movement")
@export var ground_accel: float      = 25
@export var air_accel: float         = 25
@export var max_velocity: float      = 5
@export var ground_friction: float   = 8
@export var jump_speed: float        = 8
## Lower values make it easier to gain speed. Higher values make it easier to
## change direction in the air while maintaining speed.
@export_range(0.0, 0.1, 0.001, "or_greater") var forward_coherence: float = 0.05

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$PauseMenu.visible = false

func _process(delta: float) -> void:
	
	# input
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# gravity
	velocity.y -= 25 * delta
	
	# drag (only when not frame-perfect jumping)
	if is_on_floor() and (not Input.is_action_pressed("jump") or Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		velocity = lerp(velocity, Vector3.ZERO, ground_friction * delta)
	
	print(Vector2(velocity.x, velocity.z).length())
	
	# movement
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		# walking
		if direction:
			velocity = accelerate(delta, ground_accel if is_on_floor() else air_accel, direction, velocity)
		
		# jumping
		if is_on_floor() and Input.is_action_pressed("jump"):
			velocity.y = jump_speed
	
	move_and_slide()

# https://adrianb.io/2015/02/14/bunnyhop.html
func accelerate(delta: float, accel: float, inputDirection: Vector3, prevVelocity: Vector3) -> Vector3:
	
	var projVel := prevVelocity.dot(inputDirection)
	var accelVel := accel * delta

	if (projVel + accelVel > max_velocity):
		accelVel = max_velocity - projVel

	return prevVelocity + inputDirection * accelVel

func _input(event):
	
	if event.is_action_pressed("pause"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$PauseMenu.visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$PauseMenu.visible = false
	
	if event.is_action_pressed("interact"):
		
		var query = PhysicsRayQueryParameters3D.create($Camera3D.global_position, $Camera3D.global_position - 30 * $Camera3D.global_transform.basis.z)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		if (result):
			print(result)
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		$Camera3D.rotation.x = deg_to_rad(camera_pitch)
		
		# forward coherence (try to align velocity w/ facing direction when turning)
		var forward          := Vector2(-transform.basis.z.x, -transform.basis.z.z).normalized()
		var velocity_2d      := Vector2(velocity.x, velocity.z)
		var cohered_velocity := forward * forward.dot(velocity_2d)
		var fac              := minf(velocity_2d.length() * forward_coherence * abs(event.relative.x) * mouse_sensitivity, 1.0)
		velocity.x = lerp(velocity.x, cohered_velocity.x, fac)
		velocity.z = lerp(velocity.z, cohered_velocity.y, fac)

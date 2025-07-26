extends CharacterBody3D

@export var mouse_sensitivity := 0.3

@export_group("Air Control")
@export var accel: float = 25
@export var max_velocity: float = 5

@export_group("Misc Movement")
@export var ground_friction := 8
@export var jump_speed := 8

var camera_pitch := 0.0

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$PauseMenu.visible = false

func _process(delta: float) -> void:
	
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# animation
	if not is_on_floor():
		$Model/AnimationPlayer.play("Walk", 0.4) # todo jump
	elif direction:
		$Model/AnimationPlayer.play("Walk", 0.8)
	else:
		$Model/AnimationPlayer.play("Idle", 0.8)
	
	# gravity
	velocity.y -= 25 * delta
	
	# drag (only when not frame-perfect jumping)
	if is_on_floor() and (not Input.is_action_pressed("jump") or Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		velocity = lerp(velocity, Vector3.ZERO, ground_friction * delta)
	
	# movement
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		# walking
		if direction:
			velocity = accelerate(delta, direction, velocity)
		
		# jumping
		if is_on_floor() and Input.is_action_pressed("jump"):
			velocity.y = jump_speed
	
	move_and_slide()
	
	# network syncing
	Network.broadcast(str(Network.get_client_id()) + ";" + str(position.x) + ";" + str(position.y) + ";" + str(position.z))

# https://adrianb.io/2015/02/14/bunnyhop.html
func accelerate(delta: float, inputDirection: Vector3, prevVelocity: Vector3) -> Vector3:
	
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
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		$Camera3D.rotation.x = deg_to_rad(camera_pitch)

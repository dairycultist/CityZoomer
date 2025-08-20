extends CharacterBody3D

@export var mouse_sensitivity := 0.3
var camera_pitch := 0.0

@export var gun: Node3D
@export var ammo_text: RichTextLabel

@export_group("Movement")
@export var ground_accel: float = 25
@export var air_accel: float = 25
@export var max_velocity: float = 5
@export var ground_friction := 8
@export var jump_speed := 8

@export_group("IK")
@export var left_hand: Node3D
@export var right_hand: Node3D
var left_target: Node3D
var right_target: Node3D

func _ready() -> void:
	
	if left_target:
		left_hand.target_node = left_target.get_path()
		left_hand.start()
	
	if right_target:
		right_hand.target_node = right_target.get_path()
		right_hand.start()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$PauseMenu.visible = false

func _process(delta: float) -> void:
	
	# update ammo gui
	ammo_text.text = str(gun.clip_ammo, " | ", gun.reserve_ammo)
	
	# input
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	gun.try_run(direction)
	
	# gravity
	velocity.y -= 25 * delta
	
	# drag (only when not frame-perfect jumping)
	if is_on_floor() and (not Input.is_action_pressed("jump") or Input.mouse_mode == Input.MOUSE_MODE_VISIBLE):
		velocity = lerp(velocity, Vector3.ZERO, ground_friction * delta)
	
	# movement
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		# walking
		if direction:
			velocity = accelerate(delta, ground_accel if is_on_floor() else air_accel, direction, velocity)
		
		# jumping
		if is_on_floor() and Input.is_action_pressed("jump"):
			velocity.y = jump_speed
	
	# shooting
	if Input.is_action_pressed("fire"):
		gun.try_shoot()
	
	# reloading
	if Input.is_action_just_pressed("reload"):
			gun.try_reload()
	
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
		
		if (result and result.collider.is_in_group("Loot")):
			result.collider.queue_free()
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		$Camera3D.rotation.x = deg_to_rad(camera_pitch)

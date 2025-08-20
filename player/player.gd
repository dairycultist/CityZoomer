extends CharacterBody3D

@export var mouse_sensitivity := 0.3
var camera_pitch := 0.0

@export var animation_player: AnimationPlayer

@export_group("Movement")
@export var ground_accel: float = 25
@export var air_accel: float = 25
@export var max_velocity: float = 5
@export var ground_friction := 8
@export var jump_speed := 8

@export_group("IK")
@export var left_hand: Node3D
@export var left_target: Node3D
@export var right_hand: Node3D
@export var right_target: Node3D

@export_group("Gun")
@export var firerate := 8
@export var max_clip_ammo := 50
@export var max_reserve_ammo := 200
@export var ammo_text: RichTextLabel
@export var rifle_mesh: Node3D
@export var rifle_flare_mesh: Node3D
var clip_ammo := max_clip_ammo
var reserve_ammo := max_reserve_ammo

# Rifle animation/state machine
const SHOOT_POS := Vector3(0.148, -0.19, -0.265)
const SHOOT_ROT := Vector3(deg_to_rad(5.0), deg_to_rad(173.8), 0.0)

const RUN_POS := Vector3(0, -0.3, -0.265)
const RUN_ROT := Vector3(deg_to_rad(17.4), deg_to_rad(229.6), deg_to_rad(-23.0))

const RELOAD_POS := Vector3(0.12, -0.3, -0.265)
const RELOAD_ROT := Vector3(deg_to_rad(35.6), deg_to_rad(228.9), deg_to_rad(-23.0))

var rifle_target_pos = SHOOT_POS
var rifle_target_rot = SHOOT_ROT
var animation_thread: Thread
var busy := false

func _ready() -> void:
	
	if left_target:
		left_hand.target_node = left_target.get_path()
		left_hand.start()
	
	if right_target:
		right_hand.target_node = right_target.get_path()
		right_hand.start()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_ammo_gui()
	rifle_mesh.position = rifle_target_pos
	rifle_mesh.rotation = rifle_target_rot
	$PauseMenu.visible = false

func _process(delta: float) -> void:
	
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
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
	
	move_and_slide()
	
	# animation
	if not busy:
		
		#if not is_on_floor():
			#animation_player.play("Walk", 0.4) # todo jump
		#elif direction:
			#animation_player.play("Walk", 0.8)
		#else:
			#animation_player.play("Idle", 0.8)
		
		var run_amount := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down").normalized().length()
		
		if run_amount > 0:
			
			rifle_target_pos = RUN_POS + Vector3(
				cos(Time.get_ticks_msec() * 0.01) * 0.03,
				abs(sin(Time.get_ticks_msec() * 0.01) * 0.03),
				0.0
			)
			rifle_target_rot = RUN_ROT
		else:
			rifle_target_pos = SHOOT_POS
			rifle_target_rot = SHOOT_ROT
	
	rifle_mesh.position = lerp(rifle_mesh.position, rifle_target_pos, delta * 15);
	rifle_mesh.rotation = lerp(rifle_mesh.rotation, rifle_target_rot, delta * 15);
	
	# shooting and reloading and stuff
	if Input.is_action_pressed("fire"):
		try_shoot()
	
	if Input.is_action_just_pressed("reload") and try_reload():
		$AudioReload.play()

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

func update_ammo_gui():
	ammo_text.text = str(clip_ammo, " | ", reserve_ammo)

func try_shoot() -> bool:
	
	if busy:
		return false;
	
	busy = true
	
	rifle_target_pos = SHOOT_POS
	rifle_target_rot = SHOOT_ROT
	
	rifle_mesh.position = rifle_target_pos
	rifle_mesh.rotation = rifle_target_rot
	
	if animation_thread:
		animation_thread.wait_to_finish()
	animation_thread = Thread.new()
	
	if clip_ammo > 0:
		
		clip_ammo -= 1
		update_ammo_gui()
		
		var random = RandomNumberGenerator.new()
	
		var flare_scale = random.randf_range(0.8, 1.0)
		rifle_flare_mesh.scale = Vector3(flare_scale, flare_scale, flare_scale)
		rifle_flare_mesh.visible = true
		rifle_flare_mesh.rotation.z = random.randf_range(0.0, 0.3)
		
		rifle_mesh.position.z += random.randf_range(0.1, 0.2)
		rifle_mesh.rotation.x -= random.randf_range(0.05, 0.1)
		
		$AudioGunshot.play()
		animation_thread.start(shoot_animation)
	
	else:
		$AudioDryfire.play()
		animation_thread.start(dryfire_animation)
	
	return true

func shoot_animation():
	
	for x in range(100 / firerate):
		OS.delay_msec(10)
		call_deferred("shrink_rifle_flare")
	
	rifle_flare_mesh.call_deferred("set_visible", false)
	
	busy = false

func dryfire_animation():
	
	OS.delay_msec(1000 / firerate)
	
	busy = false

func shrink_rifle_flare():
	rifle_flare_mesh.scale *= 0.95

func try_reload() -> bool:
	
	if busy or not (reserve_ammo > 0 and clip_ammo < max_clip_ammo):
		return false;
	
	rifle_target_pos = RELOAD_POS
	rifle_target_rot = RELOAD_ROT
	
	busy = true
	if animation_thread:
		animation_thread.wait_to_finish()
	animation_thread = Thread.new()
	animation_thread.start(reload_animation)
	
	return true

func reload_animation():
	
	OS.delay_msec(1000)
	
	busy = false
	
	if reserve_ammo >= max_clip_ammo - clip_ammo:
		reserve_ammo -= max_clip_ammo - clip_ammo
		clip_ammo = max_clip_ammo
	else:
		clip_ammo += reserve_ammo
		reserve_ammo = 0
	
	rifle_target_pos = SHOOT_POS
	rifle_target_rot = SHOOT_ROT
	
	call_deferred("update_ammo_gui")

func _exit_tree():
	
	if animation_thread:
		animation_thread.wait_to_finish()

class_name Player
extends CharacterBody3D

# TODO add jump pads

var camera_pitch := 0.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.3

@export_group("Game")
@export var health: int = 100

@export_group("Gunplay")
var semiautomatic_firing: bool = true
var active_gun_model: Node3D = null

var active_gun_base_pos: Vector3
var active_gun_ads_pos: Vector3

@export var recoil: float = 4.0

@export var firerate_per_sec: float = 10

var time_since_last_shot: float = 0

# spray amount is a float that goes up as you shoot
var spray: float = 0.0

@export var standing_spray_min: float = 0.0
@export var standing_spray_max: float = 1.5
@export var standing_spray_increase_rate: float = 12.0
@export var standing_spray_decrease_rate: float = 8.0

@export var running_spray_min: float = 1.0
@export var running_spray_max: float = 3.0
@export var running_spray_increase_rate: float = 20.0
@export var running_spray_decrease_rate: float = 2.0

@export_group("Movement")
@export var ground_accel: float = 50
@export var air_accel: float    = 15
@export var ads_accel: float    = 15
@export var drag: float       = 8
@export var jump_speed: float = 7
@export var gravity: float    = 20

@export_group("IK")
@export var left_hand: SkeletonIK3D
@export var right_hand: SkeletonIK3D

func set_active_gun_model(model: Node3D):
	
	# reset previous gun model
	if active_gun_model:
		active_gun_model.position = active_gun_base_pos
		active_gun_model.visible = false
	
	active_gun_model = model
	active_gun_model.visible = true
	
	active_gun_base_pos = active_gun_model.position
	# scuffed
	active_gun_ads_pos  = Vector3(0.0, active_gun_base_pos.y, active_gun_base_pos.z) / 2.0
	
	# set IK targets
	left_hand.target_node = model.get_node("LeftTargetIK").get_path()
	left_hand.start()

	right_hand.target_node = model.get_node("RightTargetIK").get_path()
	right_hand.start()
	
	# start it low so it lerps up, as an animation!
	active_gun_model.position.y = -1.0

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	set_active_gun_model($CameraAnchor/Rifle)
	
	#$Model/AnimationPlayer.current_animation = "Walk"
	#$Model/AnimationPlayer.play()

func _process(delta: float) -> void:
	
	# movement
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	_process_move(direction, Input.is_action_pressed("jump"), Input.is_action_pressed("ads"), delta)
	
	if Input.is_action_pressed("fire") if semiautomatic_firing else Input.is_action_just_pressed("fire"):
		_shoot()
	
	# rifle walk animation
	if not Input.is_action_pressed("ads"):
		active_gun_model.position.y += sin(Time.get_ticks_msec() * 0.02) * 0.3 * delta * minf(1.0, velocity.length() / 5.0)
		active_gun_model.position += Vector3(input_dir.x, 0.0, input_dir.y) * 0.01
		active_gun_model.rotation.z += input_dir.x * 0.03

func _process_move(direction, jumping: bool, ads: bool, delta: float) -> void:
	
	var grounded = is_on_floor()
	
	# gravity
	velocity.y -= gravity * delta
	
	# jumping
	if grounded and jumping:
	
		velocity.y = jump_speed
		$HopSound.pitch_scale = randf_range(0.9, 1.1)
		$HopSound.play()
		
		# make it so we're never registered as grounded, so holding
		# space lets you build up speed (by avoiding grounded speed limit)
		grounded = false
	
	# moving
	if direction:
		
		velocity += direction * ((ads_accel if ads else ground_accel) if grounded else air_accel) * delta
	
	if grounded:
		
		# drag
		velocity.x = lerp(velocity.x, 0.0, drag * delta)
		velocity.z = lerp(velocity.z, 0.0, drag * delta)
	
	move_and_slide()
	
	# gun stuff #####
	
	time_since_last_shot += delta
	
	# fade tracer
	active_gun_model.get_node("BulletTracer").scale.x = max(0.0, 1.0 - 140.0 * time_since_last_shot * time_since_last_shot)
	active_gun_model.get_node("BulletTracer").scale.y = active_gun_model.get_node("BulletTracer").scale.x
	
	# lerp rifle back to default pose
	active_gun_model.position = lerp(active_gun_model.position, active_gun_ads_pos if ads else active_gun_base_pos, 10.0 * delta)
	active_gun_model.rotation = lerp(active_gun_model.rotation, Vector3.ZERO, (20.0 if ads else 10.0) * delta)
	
	# fade muzzle flash
	active_gun_model.get_node("MuzzleFlash").scale = lerp(active_gun_model.get_node("MuzzleFlash").scale, Vector3.ZERO, 10.0 * delta)
	
	# change spray
	if time_since_last_shot < (1.0 / firerate_per_sec):
		
		# currently shooting, increase spray
		if velocity.length() > 0.1 and not ads: # running
			spray = min(running_spray_max, spray + running_spray_increase_rate * delta)
		else:
			spray = min(standing_spray_max, spray + standing_spray_increase_rate * delta)
	
	else:
		
		# not shooting, decrease spray
		if velocity.length() > 0.1 and not ads: # running
			spray = max(running_spray_min, spray - running_spray_decrease_rate * delta)
		else:
			spray = max(standing_spray_min, spray - standing_spray_decrease_rate * delta)

func _shoot():
	
	if time_since_last_shot < (1.0 / firerate_per_sec):
		return
	
	time_since_last_shot = 0.0
	
	# recoil animation
	active_gun_model.position.z += 0.05
	
	# muzzle flash
	active_gun_model.get_node("MuzzleFlash").scale = Vector3.ONE
	active_gun_model.get_node("MuzzleFlash").rotation.z = randf_range(0.0, PI * 2.0)
	
	active_gun_model.get_node("FireSound").pitch_scale = randf_range(0.95, 1.0)
	active_gun_model.get_node("FireSound").play()
	
	var end_point: Vector3 = $CameraAnchor.global_position - $CameraAnchor.global_basis.z * 500.0 + Vector3(
			randf_range(-spray, spray) * 10,
			randf_range(0, spray) * 10,
			randf_range(-spray, spray) * 10
		)
	
	var query = PhysicsRayQueryParameters3D.create(
		$CameraAnchor.global_position,
		end_point
	)
	
	query.exclude = [self]
	
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	var hit_point: Vector3 = end_point
	
	if result:
		
		hit_point = result.position
		
		if result.collider is Player:
			result.collider._damage(self, 10)
		
	active_gun_model.get_node("BulletTracer").look_at(hit_point)
	active_gun_model.get_node("BulletTracer").scale.z = hit_point.distance_to(active_gun_model.get_node("BulletTracer").global_position)

func _damage(attacker: Player, amt: int):
	print(name, " took ", amt, " damage from ", attacker.name)
	
	health -= amt
	
	if health <= 0:
		print("lethal damage taken!!")

#func _look_at(other: Player, delta: float):
	#
	#_look_towards_transform($CameraAnchor.global_transform.looking_at(other.global_position + Vector3(0., 1.5, 0.)), delta)
#
#func _look_towards_move(delta: float):
	#
	#if velocity.length() < 0.1:
		#return
	#
	#_look_towards_transform(Transform3D().looking_at(velocity), delta)
#
#func _look_towards_transform(t: Transform3D, delta: float):
	#
	#const LERP_SPEED := 10.0
	#
	#global_rotation.y = lerp_angle(global_rotation.y, t.basis.get_rotation_quaternion().get_euler().y, LERP_SPEED * delta)
	#
	#$CameraAnchor.global_rotation.x = lerp_angle($CameraAnchor.global_rotation.x, t.basis.get_rotation_quaternion().get_euler().x, LERP_SPEED * delta)
	#camera_pitch = rad_to_deg($CameraAnchor.global_rotation.x)
	#
	#$Model/Armature/Skeleton3D.set_bone_pose_rotation(
		#$Model/Armature/Skeleton3D.find_bone("Head"),
		#Quaternion.from_euler(Vector3(-deg_to_rad(camera_pitch), 0, 0))
	#)

func _change_look(d_yaw: float, d_pitch: float):
	
	rotation.y += deg_to_rad(d_yaw)
		
	camera_pitch = clampf(camera_pitch - d_pitch, -90, 90)
	
	$CameraAnchor.rotation.x = deg_to_rad(camera_pitch)
	
	$Model/Armature/Skeleton3D.set_bone_pose_rotation(
		$Model/Armature/Skeleton3D.find_bone("Head"),
		Quaternion.from_euler(Vector3(-deg_to_rad(camera_pitch), 0, 0))
	)
	
	# rifle animation
	active_gun_model.rotation.x += d_pitch * 0.004
	active_gun_model.rotation.y += d_yaw * 0.004
	active_gun_model.rotation.z -= d_yaw * 0.005
	
	# when you're in the air, if you turn your camera, your movement turns with it
	velocity = velocity.rotated(Vector3.UP, deg_to_rad(d_yaw))

func _input(event):
	
	if event.is_action_pressed("pause"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		_change_look(-event.relative.x * mouse_sensitivity, event.relative.y * mouse_sensitivity)
	
	elif event is InputEventKey and event.pressed and not event.echo:
		
		if event.keycode == KEY_1:
			semiautomatic_firing = true
			set_active_gun_model($CameraAnchor/Rifle)
		elif event.keycode == KEY_2:
			semiautomatic_firing = false
			set_active_gun_model($CameraAnchor/Pistol)

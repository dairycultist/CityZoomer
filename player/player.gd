extends CharacterBody3D

@export_group("Camera")
@export var mouse_sensitivity: float = 0.3
var camera_pitch := 0.0

@export var max_camera_distance: float = 3.0

@export_group("Movement")
@export var accel: float      = 25
@export var max_speed: float  = 5
@export var drag: float       = 8
@export var jump_speed: float = 8
@export var gravity: float    = 25

var max_speed_bonus: float = 0

@export_group("IK")
@export var left_hand: Node3D
@export var right_hand: Node3D
@export var left_target: Node3D
@export var right_target: Node3D

func _ready() -> void:
	
	$Model/AnimationPlayer.current_animation = "Walk"
	$Model/AnimationPlayer.play()
	
	if left_target:
		left_hand.target_node = left_target.get_path()
		left_hand.start()
	
	if right_target:
		right_hand.target_node = right_target.get_path()
		right_hand.start()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	
	# input
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# gravity
	velocity.y -= gravity * delta
	
	# dash
	if Input.is_action_just_pressed("altfire1"):
		
		velocity   += -transform.basis.z * max_speed * 2.0
		velocity.y += 4
		max_speed_bonus = max_speed * 2.0
		
		limit_speed()
	
	max_speed_bonus = lerp(max_speed_bonus, 0.0, delta)
	
	# leap
	if Input.is_action_just_pressed("altfire2"):
		
		velocity = direction * max_speed
		velocity.y += 13
		
		limit_speed()
	
	# moving
	if is_on_floor():
		
		if direction:
			
			velocity += direction * accel * delta
			
			limit_speed()
		
		else:
			
			# drag
			velocity.x = lerp(velocity.x, 0.0, drag * delta)
			velocity.z = lerp(velocity.z, 0.0, drag * delta)
		
	if is_on_floor() and Input.is_action_pressed("jump"):
	
		# jumping
		velocity.y = jump_speed
		$HopSound.pitch_scale = randf_range(0.9, 1.1)
		$HopSound.play()
	
	move_and_slide()
	
	# place camera
	var query = PhysicsRayQueryParameters3D.create($CameraAnchor.global_position, $CameraAnchor.global_position + max_camera_distance * $CameraAnchor.global_transform.basis.z)
	query.exclude = [get_rid()]
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if (result):
		$CameraAnchor/Camera3D.global_position = result.position
	else:
		$CameraAnchor/Camera3D.global_position = $CameraAnchor.global_position + max_camera_distance * $CameraAnchor.global_transform.basis.z

func limit_speed():
	
	var vel2d := Vector2(velocity.x, velocity.z)

	if (vel2d.length() > max_speed + max_speed_bonus):
		
		vel2d = vel2d.normalized() * (max_speed + max_speed_bonus)
		
		velocity.x = vel2d.x
		velocity.z = vel2d.y

func _input(event):
	
	if event.is_action_pressed("pause"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		var rotation_angle := deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		rotation.y += rotation_angle
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		$CameraAnchor.rotation.x = deg_to_rad(camera_pitch)
		
		# rotate velocity with camera rotation with lesser
		# magnitude proportional to rotation angle
		var rotated := Vector2(velocity.x, velocity.z).rotated(-rotation_angle).normalized()
		rotated = rotated * Vector2(velocity.x, velocity.z).dot(rotated)
		velocity.x = rotated.x
		velocity.z = rotated.y

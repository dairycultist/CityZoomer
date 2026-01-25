extends CharacterBody3D

@export_group("Camera")
@export var mouse_sensitivity: float = 0.3
var camera_pitch := 0.0

@export var max_camera_distance: float = 3.0

@export_group("Movement")
@export var ground_accel: float      = 25
@export var air_accel: float         = 25
@export var max_velocity: float      = 5
@export var jump_speed: float        = 8
## Lower values make it easier to gain speed. Higher values make it easier to
## change direction in the air while maintaining speed.
@export_range(0.0, 0.1, 0.001, "or_greater") var forward_coherence: float = 0.05

var combo_amt: int = 0

var combo_label_t: float = 0.0

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	
	# input
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# gravity
	velocity.y -= 25.0 * delta
	
	print(Vector2(velocity.x, velocity.z).length())
	
	# moving
	if direction:
		velocity = accelerate(delta, ground_accel if is_on_floor() else air_accel, direction, velocity)
	
	# jumping
	if is_on_floor():
		
		velocity.y = jump_speed
		$HopSound.pitch_scale = randf_range(0.9, 1.1)
		$HopSound.play()
		
		if combo_amt < 9:
			
			combo_amt += 1
			
			if combo_amt > 1:
				$ComboSound.pitch_scale = pow(2, (combo_amt - 1) / 12.0)
				$ComboSound.play()
				
				combo_label_t = 0.0
				$ComboLabel.text = str(combo_amt) + ("!" if combo_amt < 5 else ("!!" if combo_amt < 8 else "!?!"))
				$ComboLabel.label_settings.font_color = Color(1., 1. / combo_amt, 0.04 * combo_amt)
		
		else:
			
			combo_label_t = 0.0
			combo_amt = 0
			
			if randi() % 2 == 0:
				$ComboLabel.label_settings.font_color = Color.GREEN
				$ComboEndSound.play()
				$ComboLabel.text = "CRAZY!!"
			else:
				$ComboLabel.label_settings.font_color = Color.RED
				$ComboFailSound.play()
				$ComboLabel.text = "$%&@"
	
	@warning_ignore("integer_division")
	$ComboLabel.label_settings.font_size = max(1, lerp(lerp(0, 48 + (combo_amt / 2) * 18, pow(combo_label_t, 0.3)), 0.0, min(1.0, combo_label_t * combo_label_t)))
	combo_label_t += delta
	
	move_and_slide()
	
	# place camera
	var query = PhysicsRayQueryParameters3D.create($CameraAnchor.global_position, $CameraAnchor.global_position + max_camera_distance * $CameraAnchor.global_transform.basis.z)
	query.exclude = [get_rid()]
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if (result):
		$CameraAnchor/Camera3D.global_position = result.position
	else:
		$CameraAnchor/Camera3D.global_position = $CameraAnchor.global_position + max_camera_distance * $CameraAnchor.global_transform.basis.z

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
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		$CameraAnchor.rotation.x = deg_to_rad(camera_pitch)
		
		# forward coherence (try to align velocity w/ facing direction when turning)
		var forward          := Vector2(-transform.basis.z.x, -transform.basis.z.z).normalized()
		var velocity_2d      := Vector2(velocity.x, velocity.z)
		var cohered_velocity := forward * forward.dot(velocity_2d)
		var fac              := minf(velocity_2d.length() * forward_coherence * abs(event.relative.x) * mouse_sensitivity, 1.0)
		velocity.x = lerp(velocity.x, cohered_velocity.x, fac)
		velocity.z = lerp(velocity.z, cohered_velocity.y, fac)

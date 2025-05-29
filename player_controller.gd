extends CharacterBody3D

@export_group("Movement")
@export var mouse_sensitivity := 0.3

@export var drag := 8
@export var jump_speed := 8

@export var accel: float = 25
@export var max_velocity: float = 5

var camera_pitch := 0.0

var walk_mode := true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	
	if (position.y < -10):
		position = Vector3.ZERO
		velocity = Vector3.ZERO
	
	# movement
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity = accelerate(delta, direction, velocity)
	
	# gravity
	velocity.y -= 25 * delta
	
	# jumping
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y = jump_speed
		else:
			velocity = lerp(velocity, Vector3.ZERO, delta * drag)
	
	move_and_slide()

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
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		
		rotation.y += deg_to_rad(-event.relative.x * mouse_sensitivity)
		
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -90, 90)
		
		$Camera3D.rotation.x = deg_to_rad(camera_pitch)

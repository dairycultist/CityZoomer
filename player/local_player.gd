extends Player

@export var semiautomatic_firing: bool = true

@export_group("Camera")
@export var mouse_sensitivity: float = 0.3

func _ready() -> void:
	
	super._ready()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	
	# movement
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	_process_move(direction, Input.is_action_pressed("jump"), delta)
	
	if semiautomatic_firing:
		if Input.is_action_pressed("fire"):
			_shoot()
	else:
		if Input.is_action_just_pressed("fire"):
			_shoot()
	
	# rifle animation
	$CameraAnchor/Rifle.rotation.x = lerp($CameraAnchor/Rifle.rotation.x, 0.0, 10.0 * delta)
	$CameraAnchor/Rifle.rotation.y = lerp($CameraAnchor/Rifle.rotation.y, -PI, 10.0 * delta)
	
	# TODO make this not hardcoded
	$CameraAnchor/Rifle.position.y = -0.234 + sin(Time.get_ticks_msec() * 0.02) * 0.01 * (velocity.length() / max_speed)

func _input(event):
	
	if event.is_action_pressed("pause"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		_change_look(-event.relative.x * mouse_sensitivity, event.relative.y * mouse_sensitivity)
		
		$CameraAnchor/Rifle.rotation.x += event.relative.y * 0.001
		$CameraAnchor/Rifle.rotation.y -= event.relative.x * 0.001

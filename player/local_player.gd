extends Player

@export var semiautomatic_firing: bool = true

@export_group("Camera")
@export var mouse_sensitivity: float = 0.3

func on_fragged():
	pass

func _ready() -> void:
	
	super._ready()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	
	# movement
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	_process_move(direction, Input.is_action_pressed("jump"), Input.is_action_pressed("ads"), delta)
	
	if semiautomatic_firing:
		if Input.is_action_pressed("fire"):
			_shoot()
	else:
		if Input.is_action_just_pressed("fire"):
			_shoot()
	
	# rifle walk animation
	if not Input.is_action_pressed("ads"):
		active_gun_model.position.y += sin(Time.get_ticks_msec() * 0.02) * 0.3 * delta * (velocity.length() / max_speed)
		active_gun_model.position += Vector3(input_dir.x, 0.0, input_dir.y) * 0.01
		active_gun_model.rotation.z += input_dir.x * 0.03

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

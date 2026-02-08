extends Player

@export_group("Camera")
@export var mouse_sensitivity: float = 0.3
@export var max_camera_distance: float = 2.0

func _ready() -> void:
	
	super._ready()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	
	# movement
	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	_process_move(direction, Input.is_action_pressed("jump"), delta)
	
	if Input.is_action_pressed("fire"):
		_shoot()

func _input(event):
	
	if event.is_action_pressed("pause"):
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		_change_look(-event.relative.x * mouse_sensitivity, event.relative.y * mouse_sensitivity)

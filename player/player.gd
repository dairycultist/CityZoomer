@abstract
class_name Player
extends CharacterBody3D

@export_group("Camera")
@export var mouse_sensitivity: float = 0.3
@export var max_camera_distance: float = 3.0

var camera_pitch := 0.0

@export_group("Movement")
@export var ground_accel: float = 25
@export var air_accel: float    = 10
@export var max_speed: float  = 5
@export var drag: float       = 8
@export var jump_speed: float = 8
@export var gravity: float    = 25

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

func _process_move(direction, jumping, delta: float) -> void:
	
	# gravity
	velocity.y -= gravity * delta
	
	# moving
	if direction:
		
		if is_on_floor():
			velocity += direction * ground_accel * delta
		else:
			velocity += direction * air_accel * delta
		
		# limit speed
		var vel2d := Vector2(velocity.x, velocity.z)

		if (vel2d.length() > max_speed):
			
			vel2d = vel2d.normalized() * max_speed
			
			velocity.x = vel2d.x
			velocity.z = vel2d.y
	
	elif is_on_floor():
		
		# drag
		velocity.x = lerp(velocity.x, 0.0, drag * delta)
		velocity.z = lerp(velocity.z, 0.0, drag * delta)
		
	if is_on_floor() and jumping:
	
		# jumping
		velocity.y = jump_speed
		$HopSound.pitch_scale = randf_range(0.9, 1.1)
		$HopSound.play()
	
	move_and_slide()

func _shoot():
	
	var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		$CameraAnchor/Camera3D.global_position,
		$CameraAnchor/Camera3D.global_position - $CameraAnchor/Camera3D.global_basis.z * 50.0
	))
	
	if result:
		
		print(result.position)
		
		if result.collider is Player:
			result.collider._damage(10)

func _damage(amt: int):
	print(name, " took ", amt, " damage")

func _look_at_global(_pos: Vector3):
	pass

func _change_look(d_yaw: float, d_pitch: float):
	
	rotation.y += deg_to_rad(d_yaw)
		
	camera_pitch = clampf(camera_pitch - d_pitch, -90, 90)
	
	$CameraAnchor.rotation.x = deg_to_rad(camera_pitch)

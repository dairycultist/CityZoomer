@abstract
class_name Player
extends CharacterBody3D

var camera_pitch := 0.0

@export_group("Game")
enum Team {
	NoTeam, Attacker, Defender
}
@export var team: Team

@export_group("Gunplay")

@export var recoil: float = 3.0

@export var firerate_per_sec: float = 10

var time_since_last_shot: float = 0

# spray amount is a float that goes up as you shoot
var spray: float = 0.0

@export var standing_spray_min: float = 0.0
@export var standing_spray_max: float = 3.0
@export var standing_spray_increase_rate: float = 15.0
@export var standing_spray_decrease_rate: float = 5.0

@export var running_spray_min: float = 1.0
@export var running_spray_max: float = 4.0
@export var running_spray_increase_rate: float = 20.0
@export var running_spray_decrease_rate: float = 2.0

@export_group("Movement")
@export var ground_accel: float = 50
@export var air_accel: float    = 15
@export var max_speed: float  = 5
@export var drag: float       = 8
@export var jump_speed: float = 7
@export var gravity: float    = 20

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
	
	# duplicate material
	var material: ShaderMaterial = $Model/Armature/Skeleton3D/Mercenary.get_surface_override_material(0).duplicate()
	
	$Model/Armature/Skeleton3D/Mercenary.set_surface_override_material(0, material)
	
	match (team):
		Team.NoTeam:
			material.set("shader_parameter/color", Vector3(0.4, 0.4, 0.4));
		Team.Attacker:
			material.set("shader_parameter/color", Vector3(1.0, 0.1, 0.0));
		Team.Defender:
			material.set("shader_parameter/color", Vector3(0.1, 0.1, 1.0));

func _process_move(direction, jumping, delta: float) -> void:
	
	time_since_last_shot += delta
	
	# fade tracer
	$CameraAnchor/Rifle/BulletTracer.scale.x = max(0.0, 1.0 - 140.0 * time_since_last_shot * time_since_last_shot)
	$CameraAnchor/Rifle/BulletTracer.scale.y = $CameraAnchor/Rifle/BulletTracer.scale.x
	
	# change spray
	if time_since_last_shot < (1.0 / firerate_per_sec):
		
		# currently shooting, increase spray
		if velocity.length() > 0.1:
			spray = min(running_spray_max, spray + running_spray_increase_rate * delta)
		else:
			spray = min(standing_spray_max, spray + standing_spray_increase_rate * delta)
	
	else:
		
		# not shooting, decrease spray
		if velocity.length() > 0.1:
			spray = max(running_spray_min, spray - running_spray_decrease_rate * delta)
		else:
			spray = max(standing_spray_min, spray - standing_spray_decrease_rate * delta)
	
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
	
	if time_since_last_shot < (1.0 / firerate_per_sec):
		return
	
	time_since_last_shot = 0.0
	
	_change_look(0.0, -recoil)
	
	var query = PhysicsRayQueryParameters3D.create(
		$CameraAnchor.global_position,
		$CameraAnchor.global_position - $CameraAnchor.global_basis.z * 50.0
		+ Vector3(
			randf_range(-spray, spray),
			randf_range(0, spray),
			randf_range(-spray, spray)
		)
	)
	
	query.exclude = [self]
	
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result:
		
		$CameraAnchor/Rifle/BulletTracer.look_at(result.position)
		$CameraAnchor/Rifle/BulletTracer.scale.z = result.position.distance_to($CameraAnchor/Rifle/BulletTracer.global_position)
		
		if result.collider is Player:
			result.collider._damage(self, 10)

func _damage(attacker: Player, amt: int):
	print(name, " took ", amt, " damage from ", attacker.name)

func _look_at(other: Player):
	
	var temp_transform: Transform3D = $CameraAnchor.global_transform.looking_at(other.global_position + Vector3(0., 1., 0.))
	
	rotation.y = temp_transform.basis.get_rotation_quaternion().get_euler().y
	
	$CameraAnchor.rotation.x = temp_transform.basis.get_rotation_quaternion().get_euler().x
	camera_pitch = rad_to_deg($CameraAnchor.rotation.x)

func _change_look(d_yaw: float, d_pitch: float):
	
	rotation.y += deg_to_rad(d_yaw)
		
	camera_pitch = clampf(camera_pitch - d_pitch, -90, 90)
	
	$CameraAnchor.rotation.x = deg_to_rad(camera_pitch)

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

@export var recoil: float = 4.0

@export var firerate_per_sec: float = 10

var time_since_last_shot: float = 0

# spray amount is a float that goes up as you shoot
var spray: float = 0.0

var rifle_base_pos: Vector3

@export var standing_spray_min: float = 0.0
@export var standing_spray_max: float = 1.5
@export var standing_spray_increase_rate: float = 12.0
@export var standing_spray_decrease_rate: float = 8.0

@export var moving_spray_min: float = 1.0
@export var moving_spray_max: float = 3.0
@export var moving_spray_increase_rate: float = 20.0
@export var moving_spray_decrease_rate: float = 2.0

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
	
	rifle_base_pos = $CameraAnchor/Rifle.position
	
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
		if velocity.length() > 0.1: # moving
			spray = min(moving_spray_max, spray + moving_spray_increase_rate * delta)
		else:
			spray = min(standing_spray_max, spray + standing_spray_increase_rate * delta)
	
	else:
		
		# not shooting, decrease spray
		if velocity.length() > 0.1: # moving
			spray = max(moving_spray_min, spray - moving_spray_decrease_rate * delta)
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
	
	# lerp rifle back to default pose
	$CameraAnchor/Rifle.position = lerp($CameraAnchor/Rifle.position, rifle_base_pos, 10.0 * delta)
	$CameraAnchor/Rifle.rotation = lerp($CameraAnchor/Rifle.rotation, Vector3(0.0, -PI, 0.0), 10.0 * delta)

func _shoot():
	
	if time_since_last_shot < (1.0 / firerate_per_sec):
		return
	
	time_since_last_shot = 0.0
	
	# recoil animation
	$CameraAnchor/Rifle.position.z += 0.05
	
	$FireSound.pitch_scale = randf_range(0.95, 1.0)
	$FireSound.play()
	
	var query = PhysicsRayQueryParameters3D.create(
		$CameraAnchor.global_position,
		$CameraAnchor.global_position - $CameraAnchor.global_basis.z * 500.0
		+ Vector3(
			randf_range(-spray, spray) * 10,
			randf_range(0, spray) * 10,
			randf_range(-spray, spray) * 10
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

func _look_at(other: Player, delta: float):
	
	_look_towards_transform($CameraAnchor.global_transform.looking_at(other.global_position + Vector3(0., 1.5, 0.)), delta)

func _look_towards_move(delta: float):
	
	if velocity.length() < 0.1:
		return
	
	_look_towards_transform(Transform3D().looking_at(velocity), delta)

func _look_towards_transform(t: Transform3D, delta: float):
	
	const LERP_SPEED := 10.0
	
	global_rotation.y = lerp_angle(global_rotation.y, t.basis.get_rotation_quaternion().get_euler().y, LERP_SPEED * delta)
	
	$CameraAnchor.global_rotation.x = lerp_angle($CameraAnchor.global_rotation.x, t.basis.get_rotation_quaternion().get_euler().x, LERP_SPEED * delta)
	camera_pitch = rad_to_deg($CameraAnchor.global_rotation.x)
	
	$Model/Armature/Skeleton3D.set_bone_pose_rotation(
		$Model/Armature/Skeleton3D.find_bone("Head"),
		Quaternion.from_euler(Vector3(-deg_to_rad(camera_pitch), 0, 0))
	)

func _change_look(d_yaw: float, d_pitch: float):
	
	rotation.y += deg_to_rad(d_yaw)
		
	camera_pitch = clampf(camera_pitch - d_pitch, -90, 90)
	
	$CameraAnchor.rotation.x = deg_to_rad(camera_pitch)
	
	$Model/Armature/Skeleton3D.set_bone_pose_rotation(
		$Model/Armature/Skeleton3D.find_bone("Head"),
		Quaternion.from_euler(Vector3(-deg_to_rad(camera_pitch), 0, 0))
	)
	
	# rifle animation
	$CameraAnchor/Rifle.rotation.x += d_pitch * 0.004
	$CameraAnchor/Rifle.rotation.y += d_yaw * 0.004
	$CameraAnchor/Rifle.rotation.z -= d_yaw * 0.005

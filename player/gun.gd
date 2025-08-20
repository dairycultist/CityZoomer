extends Node3D

# TODO implement gun hotswapping system
# TODO (lets you change mesh, animation, fire properties...)

@export_group("Gunplay")
@export var firerate := 8
@export var max_clip_ammo := 50
@export var max_reserve_ammo := 200
var clip_ammo := max_clip_ammo
var reserve_ammo := max_reserve_ammo

@export_group("Animation")
@export var rifle_mesh: Node3D
@export var rifle_flare_mesh: Node3D

# Rifle animation/state machine
const SHOOT_POS := Vector3(0.148, -0.19, -0.265)
const SHOOT_ROT := Vector3(deg_to_rad(5.0), deg_to_rad(173.8), 0.0)

const RUN_POS := Vector3(0, -0.3, -0.265)
const RUN_ROT := Vector3(deg_to_rad(17.4), deg_to_rad(229.6), deg_to_rad(-23.0))

const RELOAD_POS := Vector3(0.12, -0.3, -0.265)
const RELOAD_ROT := Vector3(deg_to_rad(35.6), deg_to_rad(228.9), deg_to_rad(-23.0))

var rifle_target_pos = SHOOT_POS
var rifle_target_rot = SHOOT_ROT
var animation_thread: Thread
var busy := false

func _ready() -> void:
	rifle_mesh.position = rifle_target_pos
	rifle_mesh.rotation = rifle_target_rot

func _process(delta: float) -> void:
	rifle_mesh.position = lerp(rifle_mesh.position, rifle_target_pos, delta * 15);
	rifle_mesh.rotation = lerp(rifle_mesh.rotation, rifle_target_rot, delta * 15);

func try_run(direction: Vector3) -> void:
	
	if busy:
		return
	
	#if not is_on_floor():
		#animation_player.play("Walk", 0.4) # todo jump
	#elif direction:
		#animation_player.play("Walk", 0.8)
	#else:
		#animation_player.play("Idle", 0.8)
	
	if direction:
		rifle_target_pos = RUN_POS + Vector3(
			cos(Time.get_ticks_msec() * 0.01) * 0.03,
			abs(sin(Time.get_ticks_msec() * 0.01) * 0.03),
			0.0
		)
		rifle_target_rot = RUN_ROT
	else:
		rifle_target_pos = SHOOT_POS
		rifle_target_rot = SHOOT_ROT

func try_shoot() -> void:
	# returns true if used ammo
	
	if busy:
		return
	
	busy = true
	
	rifle_target_pos = SHOOT_POS
	rifle_target_rot = SHOOT_ROT
	
	rifle_mesh.position = rifle_target_pos
	rifle_mesh.rotation = rifle_target_rot
	
	if animation_thread:
		animation_thread.wait_to_finish()
	animation_thread = Thread.new()
	
	if clip_ammo > 0:
		
		clip_ammo -= 1
		
		var random = RandomNumberGenerator.new()
	
		var flare_scale = random.randf_range(0.8, 1.0)
		rifle_flare_mesh.scale = Vector3(flare_scale, flare_scale, flare_scale)
		rifle_flare_mesh.visible = true
		rifle_flare_mesh.rotation.z = random.randf_range(0.0, 0.3)
		
		rifle_mesh.position.z += random.randf_range(0.1, 0.2)
		rifle_mesh.rotation.x -= random.randf_range(0.05, 0.1)
		
		$AudioGunshot.play()
		animation_thread.start(shoot_animation.bind(firerate))
	
	else:
		$AudioDryfire.play()
		animation_thread.start(dryfire_animation.bind(firerate))

func shoot_animation(firerate: int) -> void:
	
	for x in range(100 / firerate):
		OS.delay_msec(10)
		call_deferred("shrink_rifle_flare")
	
	rifle_flare_mesh.call_deferred("set_visible", false)
	
	busy = false

func dryfire_animation(firerate: int) -> void:
	
	OS.delay_msec(1000 / firerate)
	
	busy = false

func shrink_rifle_flare() -> void:
	rifle_flare_mesh.scale *= 0.95

func try_reload() -> void:
	
	if busy or reserve_ammo == 0 or clip_ammo == max_clip_ammo:
		return
	
	$AudioReload.play()
	
	rifle_target_pos = RELOAD_POS
	rifle_target_rot = RELOAD_ROT
	
	busy = true
	if animation_thread:
		animation_thread.wait_to_finish()
	animation_thread = Thread.new()
	animation_thread.start(reload_animation)

func reload_animation() -> void:
	
	OS.delay_msec(1000) # will be longer for intense duck-and-cover moments
	
	if reserve_ammo >= max_clip_ammo - clip_ammo:
		reserve_ammo -= max_clip_ammo - clip_ammo
		clip_ammo = max_clip_ammo
	else:
		clip_ammo += reserve_ammo
		reserve_ammo = 0
	
	busy = false
	
	rifle_target_pos = SHOOT_POS
	rifle_target_rot = SHOOT_ROT

func _exit_tree() -> void:
	
	if animation_thread:
		animation_thread.wait_to_finish()

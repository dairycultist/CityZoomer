extends Node3D

# Rifle animation/state machine
#
const SHOOT_POS := Vector3(0.65, -0.44, -0.74)
const SHOOT_ROT := Vector3(deg_to_rad(5.0), deg_to_rad(173.8), 0.0)

const RUN_POS := Vector3(0, -0.5, -0.63)
const RUN_ROT := Vector3(deg_to_rad(17.4), deg_to_rad(229.6), deg_to_rad(-23.0))

const RELOAD_POS := Vector3(0.11, -0.6, -0.59)
const RELOAD_ROT := Vector3(deg_to_rad(35.6), deg_to_rad(228.9), deg_to_rad(-23.0))

@onready var rifle := $GUIGunOverlay/GunOverlay/Camera3D/Rifle
@onready var rifle_flare := $GUIGunOverlay/GunOverlay/Camera3D/Rifle/MuzzleFlare

var rifle_target_pos = SHOOT_POS
var rifle_target_rot = SHOOT_ROT

var animation_thread: Thread
var busy := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	rifle.position = rifle_target_pos
	rifle.rotation = rifle_target_rot

func _process(delta: float) -> void:
	
	if not busy:
		
		var run_amount := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down").normalized().length()
		
		if run_amount > 0:
			
			rifle_target_pos = RUN_POS + Vector3(
				cos(Time.get_ticks_msec() * 0.01) * 0.03,
				abs(sin(Time.get_ticks_msec() * 0.01) * 0.03),
				0.0
			)
			rifle_target_rot = RUN_ROT
		else:
			rifle_target_pos = SHOOT_POS
			rifle_target_rot = SHOOT_ROT
	
	rifle.position = lerp(rifle.position, rifle_target_pos, delta * 15);
	rifle.rotation = lerp(rifle.rotation, rifle_target_rot, delta * 15);
	
	# shooting and reloading and stuff
	if Input.is_action_pressed("fire"):
		try_shoot()
	
	if Input.is_action_just_pressed("reload") and try_reload():
		$AudioReload.play()

func try_shoot() -> bool:
	
	if busy:
		return false;
	
	busy = true
	
	rifle_target_pos = SHOOT_POS
	rifle_target_rot = SHOOT_ROT
	
	rifle.position = rifle_target_pos
	rifle.rotation = rifle_target_rot
	
	if animation_thread:
		animation_thread.wait_to_finish()
	animation_thread = Thread.new()
	
	if clip_ammo > 0:
		
		clip_ammo -= 1
		update_ammo_gui()
		
		var random = RandomNumberGenerator.new()
	
		var flare_scale = random.randf_range(0.8, 1.0)
		rifle_flare.scale = Vector3(flare_scale, flare_scale, flare_scale)
		rifle_flare.visible = true
		rifle_flare.rotation.z = random.randf_range(0.0, 0.3)
		
		rifle.position.z += random.randf_range(0.1, 0.2)
		rifle.rotation.x -= random.randf_range(0.05, 0.1)
		
		$AudioGunshot.play()
		animation_thread.start(shoot_animation)
	
	else:
		$AudioDryfire.play()
		animation_thread.start(dryfire_animation)
	
	return true

func shoot_animation():
	
	for x in range(100 / firerate):
		OS.delay_msec(10)
		call_deferred("shrink_rifle_flare")
	
	rifle_flare.call_deferred("set_visible", false)
	
	busy = false

func dryfire_animation():
	
	OS.delay_msec(1000 / firerate)
	
	busy = false

func shrink_rifle_flare():
	rifle_flare.scale *= 0.95

func try_reload() -> bool:
	
	if busy or not (reserve_ammo > 0 and clip_ammo < max_clip_ammo):
		return false;
	
	rifle_target_pos = RELOAD_POS
	rifle_target_rot = RELOAD_ROT
	
	busy = true
	if animation_thread:
		animation_thread.wait_to_finish()
	animation_thread = Thread.new()
	animation_thread.start(reload_animation)
	
	return true

func reload_animation():
	
	OS.delay_msec(1000)
	
	busy = false
	
	if reserve_ammo >= max_clip_ammo - clip_ammo:
		reserve_ammo -= max_clip_ammo - clip_ammo
		clip_ammo = max_clip_ammo
	else:
		clip_ammo += reserve_ammo
		reserve_ammo = 0
	
	rifle_target_pos = SHOOT_POS
	rifle_target_rot = SHOOT_ROT
	
	call_deferred("update_ammo_gui")



func _exit_tree():
	
	if animation_thread:
		animation_thread.wait_to_finish()

extends Node3D

@export var left_target: Node3D
@export var right_target: Node3D

func _ready() -> void:
	
	if left_target:
		$Armature/Skeleton3D/LeftHandIK.target_node = left_target.get_path()
		$Armature/Skeleton3D/LeftHandIK.start()
	
	if right_target:
		$Armature/Skeleton3D/RightHandIK.target_node = right_target.get_path()
		$Armature/Skeleton3D/RightHandIK.start()
	
	# temp, mostly just for the title screen
	$AnimationPlayer.play("Walk")

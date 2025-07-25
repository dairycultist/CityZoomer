extends Button

@export var scene: String = "res://"

func _ready() -> void:
	
	pressed.connect(on_pressed)

func on_pressed() -> void:

	get_tree().change_scene_to_file(scene)

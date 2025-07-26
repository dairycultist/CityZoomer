extends Button

enum NetworkAction {  
	START_SERVER_CLIENT,     # put into lobby
	START_REMOTE_CLIENT,     # put into lobby
	STOP,                    # put into main menu
	SERVER_CLIENT_LOAD_SCENE # put into scene
}

@export var type: NetworkAction
@export var scene: String = "res://UNUSED"

func _ready() -> void:
	
	if type == NetworkAction.SERVER_CLIENT_LOAD_SCENE and Network.is_remoteclient():
		self.disabled = true
	
	pressed.connect(on_pressed)

func on_pressed() -> void:
	
	match type:
		
		NetworkAction.START_SERVER_CLIENT:
			Network.start_serverclient(3000)
		
		NetworkAction.START_REMOTE_CLIENT:
			Network.start_remoteclient("127.0.0.1", 3000)
		
		NetworkAction.STOP:
			Network.stop()
		
		NetworkAction.SERVER_CLIENT_LOAD_SCENE:
			Network.serverclient_broadcast_change_scene(scene)

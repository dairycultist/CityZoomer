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
	
	match type:
		
		NetworkAction.SERVER_CLIENT_LOAD_SCENE:
			
			if Network.is_client():
				self.disabled = true
	
		NetworkAction.STOP:
			
			if Network.is_client():
				text = "Disconnect"
			else:
				text = "Stop Server"
	
	pressed.connect(on_pressed)

func on_pressed() -> void:
	
	match type:
		
		NetworkAction.START_SERVER_CLIENT:
			Network.start_server(3000)
		
		NetworkAction.START_REMOTE_CLIENT:
			Network.start_client("127.0.0.1", 3000)
		
		NetworkAction.STOP:
			Network.stop()
		
		NetworkAction.SERVER_CLIENT_LOAD_SCENE:
			# only serverclient will be able to call this
			Network.broadcast(Network.MessageType.CHANGE_SCENE, scene)

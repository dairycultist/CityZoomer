extends Button

enum NetworkAction {  
	START_SERVER_CLIENT,        # put into lobby
	START_REMOTE_CLIENT,        # put into lobby
	STOP,                       # put into main menu
	SERVER_CLIENT_LOAD_GAMEMODE # put into selected gamemode
}

@export var type: NetworkAction
@export var gamemode: String = "res://UNUSED"

const LOBBY := "res://network/lobby.tscn"
const MAIN_MENU := "res://network/main_menu.tscn"

func _ready() -> void:
	
	if type == NetworkAction.SERVER_CLIENT_LOAD_GAMEMODE and Network.is_remoteclient():
		self.disabled = true
	
	pressed.connect(on_pressed)

func on_pressed() -> void:
	
	match type:
		
		NetworkAction.START_SERVER_CLIENT:
			Network.start_serverclient()
			get_tree().change_scene_to_file(LOBBY)
		
		NetworkAction.START_REMOTE_CLIENT:
			Network.start_remoteclient(0, 0)
			get_tree().change_scene_to_file(LOBBY)
		
		NetworkAction.STOP:
			Network.stop()
			get_tree().change_scene_to_file(MAIN_MENU)
		
		NetworkAction.SERVER_CLIENT_LOAD_GAMEMODE:
			Network.serverclient_broadcast_change_scene(gamemode)

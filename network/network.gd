extends Node

# lobby appears different depending on if you're a remote client or
# a server client ("waiting on server to choose gamemode...")

# the serverclient keeps track of all the remoteclients

# https://docs.godotengine.org/en/stable/classes/class_tcpserver.html

# allows initialization of newly joined players
# see that a player joined? send them a signal to spawn you!

signal remoteclient_joined # (client_id: int)
signal remoteclient_left # (client_id: int)
signal data_recieved # (data: String)

enum ClientType {
	NO_CONNECTION,
	SERVER_CLIENT,
	REMOTE_CLIENT
}

var _client_type := ClientType.NO_CONNECTION
var _client_id: int

func start_serverclient() -> bool:
	
	# go to lobby
	
	return false

func start_remoteclient(ip, port) -> bool:
	
	# wait for server to respond with your client id
	
	# the server will also send you a message telling you what
	# scene to load
	
	return false

# destroys the (connection to) TCP server
func stop() -> void:
	get_tree().change_scene_to_file("res://network/main_menu.tscn")

func broadcast(data: String) -> void:
	
	if is_remoteclient():
		# send to serverclient, telling them to broadcast
		# also append an ID header to the data so that they know
		# not to send it back to whoever sent it
		
		send_to(0, "[broadcastfrom|" + str(get_client_id()) + "]" + data)
	else:
		# send to all remote clients
		pass

func send_to(client_id: int, data: String):
	pass

func serverclient_broadcast_change_scene(scene: String) -> void:
	get_tree().change_scene_to_file(scene)

func get_client_id() -> int:
	
	match _client_type:
	
		ClientType.NO_CONNECTION:
			return -1
		
		ClientType.SERVER_CLIENT:
			return 0 # serverclient's client_id is always 0
	
	return _client_id

func is_serverclient() -> bool:
	return _client_type == ClientType.SERVER_CLIENT

func is_remoteclient() -> bool:
	return _client_type == ClientType.REMOTE_CLIENT

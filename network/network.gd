extends Node

# ALL METHODS ON THIS GLOBAL SHOULD BE SERVER/REMOTE AGNOSTIC. THE PROGRAMMER
# SHOULD ONLY CARE ABOUT WHAT SIDE THEY'RE ON IF THEY SPECIFICALLY CALL
# is_serverclient() OR is_remoteclient()

# lobby appears different depending on if you're a remote client or
# a server client ("waiting on server to choose gamemode...")

# the serverclient keeps track of all the remoteclients

# allows initialization of newly joined players
# see that a player joined? send them a signal to spawn you!

signal remoteclient_joined # (client_id: int)
signal remoteclient_left # (client_id: int)
signal serverclient_left # ()
signal data_recieved # (data: String)

enum ClientType {
	NO_CONNECTION,
	SERVER_CLIENT,
	REMOTE_CLIENT
}

var _client_type := ClientType.NO_CONNECTION
var _client_id: int # technically not used by serverclient since will always be 0

# serverclient only
var _tcp_server: TCPServer
var _tcp_server_connected_clients: Dictionary # int:StreamPeerTCP

# remoteclient only
var _tcp_remote: StreamPeerTCP



func _process(delta: float) -> void:
	
	# both the server and client have special messages they may recieve
	# that are labeled with prepended headers. only if the message does
	# not contain such headers will they proceed to send a data_recieved signal
	match _client_type:
		
		ClientType.SERVER_CLIENT:
			
			# accept any new connections
			if _tcp_server.is_connection_available():
				# TODO
				_tcp_server.take_connection()
				
				# respond with client id "[SET_CLIENT_ID]1"
				# respond with what scene to load "[CHANGE_SCENE]blah"
	
		ClientType.REMOTE_CLIENT:
			
			# update state
			_tcp_remote.poll()
			
			if _tcp_remote.get_available_bytes() > 0:
				# TODO
				print(_tcp_remote.get_string())

func start_serverclient(port: int) -> bool:
	
	# https://docs.godotengine.org/en/stable/classes/class_tcpserver.html
	_tcp_server = TCPServer.new()
	
	# start server
	var error := _tcp_server.listen(port)
	
	if error != Error.OK:
		push_error("start_serverclient error " + str(error) + ": " + error_string(error))
		return false
	
	_client_type = ClientType.SERVER_CLIENT
	
	# update game state
	get_tree().change_scene_to_file("res://network/lobby.tscn")
	
	return true

func start_remoteclient(ip: String, port: int) -> bool:
	
	# https://docs.godotengine.org/en/stable/classes/class_streampeertcp.html
	_tcp_remote = StreamPeerTCP.new()
	
	# start remote connection
	var error := _tcp_remote.connect_to_host(ip, port)
	
	if error != Error.OK:
		push_error("start_remoteclient error " + str(error) + ": " + error_string(error))
		return false
	
	_client_type = ClientType.REMOTE_CLIENT
	
	return true

# destroys the (connection to) TCP server
func stop() -> void:
	
	match _client_type:
		
		ClientType.SERVER_CLIENT:
			_tcp_server.stop()
			_tcp_server = null
		
		ClientType.REMOTE_CLIENT:
			_tcp_remote.disconnect_from_host()
			_tcp_remote = null
	
	_client_type = ClientType.NO_CONNECTION
	get_tree().change_scene_to_file("res://network/main_menu.tscn")

func broadcast(data: String) -> void:
	
	if is_remoteclient():
		# send to serverclient, telling them to broadcast
		# also append an ID header to the data so that they know
		# not to send it back to whoever sent it
		
		send_to(0, "[BROADCAST][" + str(get_client_id()) + "]" + data)
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

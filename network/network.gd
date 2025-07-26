extends Node

# ALL METHODS ON THIS GLOBAL SHOULD BE SERVER/CLIENT AGNOSTIC. THE PROGRAMMER
# SHOULD ONLY CARE ABOUT WHAT SIDE THEY'RE ON IF THEY SPECIFICALLY CALL
# is_server() OR is_client()

signal client_joined # (id: int)
signal client_left # (id: int)
signal data_recieved # (data: String)

# remember, the server itself has its own player
enum ConnectionType { NONE, SERVER, CLIENT }

enum MessageType {
	SET_ID,
	CHANGE_SCENE, # get_tree().change_scene_to_file(scene)
	PASS_ON, # client asking server to not read a message and just send it to another client
	REQUEST_BROADCAST, # client asking server to broadcast to everyone else
	ARBITRARY, # not handled automatically, just calls data_recieved signal w/ data
	DONT_ADD_HEADER # in case you're rerouting data that already has headers
}

var _conn_type := ConnectionType.NONE
var _id: int # technically not used by server since it will always be 0

# SERVER ONLY
# the server keeps track of all the connected clients
var _tcp_server: TCPServer
var _tcp_connected_clients: Dictionary # int:StreamPeerTCP

# CLIENT ONLY
var _tcp_client: StreamPeerTCP



func _process(_delta: float) -> void:
	
	# both the server and client have special messages they may recieve
	# that are labeled with prepended headers. only if the message does
	# not contain such headers will they proceed to send a data_recieved signal
	match _conn_type:
		
		ConnectionType.SERVER:
			
			# recieve from active connections
			
			# accept any new connections
			if _tcp_server.is_connection_available():
				
				var socket := _tcp_server.take_connection()
				
				# assign an id to the connection
				var socket_id := RandomNumberGenerator.new().randi_range(0, 1000)
				while (_tcp_connected_clients.has(socket_id)):
					socket_id = RandomNumberGenerator.new().randi_range(0, 1000)
				
				_tcp_connected_clients.set(socket_id, socket)
				
				# send client id + what scene to load
				send_to(MessageType.SET_ID, socket_id, str(socket_id))
				#send_to(MessageType.CHANGE_SCENE, id, "")
				
				# tell everyone who joined
				client_joined.emit(socket_id)
	
		ConnectionType.CLIENT:
			
			# update state
			_tcp_client.poll()
			
			# check if the connection is still open
			# (or if it is down, indicating the server closed)
			match _tcp_client.get_status():
				
				StreamPeerTCP.Status.STATUS_CONNECTED:
					if _tcp_client.get_available_bytes() > 0:
						# TODO
						print(_tcp_client.get_string())
				
				StreamPeerTCP.Status.STATUS_NONE or StreamPeerTCP.Status.STATUS_ERROR:
					stop()

func start_server(port: int) -> bool:
	
	# https://docs.godotengine.org/en/stable/classes/class_tcpserver.html
	_tcp_server = TCPServer.new()
	
	# start server
	var error := _tcp_server.listen(port)
	
	if error != Error.OK:
		push_error("start_server error " + str(error) + ": " + error_string(error))
		return false
	
	_conn_type = ConnectionType.SERVER
	
	# update game state
	get_tree().change_scene_to_file("res://network/lobby.tscn")
	
	return true

func start_client(ip: String, port: int) -> bool:
	
	# https://docs.godotengine.org/en/stable/classes/class_streampeertcp.html
	_tcp_client = StreamPeerTCP.new()
	
	# start client connection to server
	var error := _tcp_client.connect_to_host(ip, port)
	
	if error != Error.OK:
		push_error("start_client error " + str(error) + ": " + error_string(error))
		return false
	
	_conn_type = ConnectionType.CLIENT
	
	return true

func broadcast(type: MessageType, data: String) -> void:
	
	match _conn_type:
		
		ConnectionType.SERVER:
			
			var id_to_ignore := -1
			
			# parse out the id_to_ignore if this is a client-requested broadcast
			if data.begins_with("REQUEST_BROADCAST;"):
				
				var parts := data.split(";", true, 2)
				id_to_ignore = parts[1].to_int()
				data = parts[2]
			
			# send to all connected clients
			for id in _tcp_connected_clients.keys():
				if id != id_to_ignore:
					send_to(type, id, data)
		
		ConnectionType.CLIENT:
			
			send_to(MessageType.REQUEST_BROADCAST, 0, add_header(type, data))

func send_to(type: MessageType, client_id: int, data: String):
	
	data = add_header(type, data)
	
	match _conn_type:
		
		ConnectionType.SERVER:
			
			var socket = _tcp_connected_clients.get(client_id)
			if socket != null:
				socket.put_data(data.to_ascii_buffer())
		
		ConnectionType.CLIENT:
			
			if client_id == 0:
				_tcp_client.put_data(data.to_ascii_buffer())
			else:
				pass
				# need to use PASS_ON, which doesn't exist yet

func add_header(type: MessageType, data: String) -> String:
	
	match type:
		
		MessageType.SET_ID:
			return "SET_ID;" + data
		
		MessageType.CHANGE_SCENE:
			return "CHANGE_SCENE;" + data
		
		MessageType.REQUEST_BROADCAST:
			return "REQUEST_BROADCAST;" + str(get_id()) + ";" + data
	
	return data



func stop() -> void:
	
	match _conn_type:
		
		ConnectionType.SERVER:
			_tcp_server.stop()
			_tcp_server = null
		
		ConnectionType.CLIENT:
			_tcp_client.disconnect_from_host()
			_tcp_client = null
	
	_conn_type = ConnectionType.NONE
	get_tree().change_scene_to_file("res://network/main_menu.tscn")

func get_id() -> int:
	match _conn_type:
		ConnectionType.NONE:   return -1
		ConnectionType.SERVER: return 0 # server's _id is always 0
		_:                     return _id

func is_server() -> bool:
	return _conn_type == ConnectionType.SERVER

func is_client() -> bool:
	return _conn_type == ConnectionType.CLIENT

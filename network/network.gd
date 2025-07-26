extends Node

# (singleplayer is just a local server)

# lobby appears different depending on if you're a remote client or
# a server client

# the serverclient keeps track of all the remoteclients and sends them data
# Network iterates through every NetworkBehaviour node every network tick, sending
# data that isn't empty and passing recieved data to the corresponding node. when
# sending, the Network automatically bundles the sender's nodepath so that the
# reciever can pass it to the corresponding node on their end.

# https://docs.godotengine.org/en/stable/classes/class_tcpserver.html

# allows initialization of newly joined players
# see that a player joined? send them a signal to spawn you!
signal remoteclient_joined # (client_id: int)
signal remoteclient_left # (client_id: int)
signal data_recieved # (data: String)

func start_serverclient() -> bool:
	return false

func start_remoteclient(ip, port) -> bool:
	return false

# destroys the (connection to) TCP server
func stop() -> void:
	pass

func broadcast(data: String) -> void:
	
	if is_remoteclient():
		# send to serverclient, telling them to broadcast
		# also append an ID header to the data so that they know
		# not to send it back to whoever sent it
		pass
	else:
		# send to all remote clients
		pass

func send_to(client_id: int, data: String):
	pass

func serverclient_broadcast_change_scene(scene: String) -> void:
	get_tree().change_scene_to_file(scene)

func get_client_id() -> int:
	return 0

func is_serverclient() -> bool:
	return false

func is_remoteclient() -> bool:
	return false

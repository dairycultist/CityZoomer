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

func start_serverclient() -> bool:
	return false

func start_remoteclient(ip, port) -> bool:
	return false

# destroys the TCP server
func stop() -> void:
	pass

func serverclient_broadcast_change_scene(scene: String) -> void:
	get_tree().change_scene_to_file(scene)

func is_serverclient() -> bool:
	return false

func is_remoteclient() -> bool:
	return false

#must be added to group NetworkBehaviour for these methods to be called by Network:
#
#```
#serverclient_send(remoteclient_id: int) -> String
#serverclient_recieve(remoteclient_id: int, data: String) -> void
#
#remoteclient_send() -> String
#remoteclient_recieve(data: String) -> void
#```

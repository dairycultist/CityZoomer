extends Node

# title screen: button for singleplayer/host server (since singleplayer is just
# a local server) or join server

# serverclient lobby screen: the actual gamemode selection

# remoteclient lobby screen: "waiting for server to select gamemode..."

# the serverclient keeps track of all the remoteclients and sends them data
# Network iterates through every NetworkBehaviour node every network tick, sending
# data that isn't empty and passing recieved data to the corresponding node. when
# sending, the Network automatically bundles the sender's nodepath so that the
# reciever can pass it to the corresponding node on their end.

# https://docs.godotengine.org/en/stable/classes/class_tcpserver.html

func start_serverclient() -> void:
	pass

func start_remoteclient(ip, port) -> void:
	pass

# destroys the TCP server
func stop() -> void:
	pass

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

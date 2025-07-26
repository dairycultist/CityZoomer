extends AnimatableBody3D

# NetworkBehaviour-specific methods
func serverclient_send(remoteclient_id: int) -> String:
	return ""

func serverclient_recieve(remoteclient_id: int, data: String) -> void:
	
	remoteclient_recieve(data)

func remoteclient_send() -> String:
	return ""

func remoteclient_recieve(data: String) -> void:
	
	var arr := data.split(";")
	
	position.x = arr[0].to_int()
	position.y = arr[1].to_int()
	position.z = arr[2].to_int()

extends AnimatableBody3D

var associated_client_id: int

func _ready() -> void:
	
	Network.data_recieved.connect(on_data_recieved)

func on_data_recieved(data: String) -> void:
	
	var arr := data.split(";")
	
	# if the first part is the client ID associated with this puppet,
	# the next parts will be the position we should sync to
	if associated_client_id == arr[0].to_int():
	
		position.x = arr[1].to_int()
		position.y = arr[2].to_int()
		position.z = arr[3].to_int()

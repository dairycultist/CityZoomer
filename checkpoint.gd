extends Area3D

func _ready() -> void:
	self.body_entered.connect(_test_for_player)

func _test_for_player(_area: Node3D):
	
	# remember to check that it is the player entering and not something else
	print("test")

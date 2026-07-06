extends Node

@export var player_scene : PackedScene


func _ready() -> void:
	# For testing purposes
	var player = player_scene.instantiate()
	
	player.position = Vector3(0, 0, 0)
	
	add_child(player)

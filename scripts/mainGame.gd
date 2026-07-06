extends Node

@export var player_scene : PackedScene

@onready var players_folder := $Players

func _ready() -> void:
	# For testing purposes
	var player = player_scene.instantiate()
	
	player.position = Vector3(0, 0, 0)
	
	players_folder.add_child(player)

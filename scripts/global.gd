extends Node

const PORT = 9999

var arguments : Dictionary = {}


func change_scene_with_arguments(scene_path, args = {}) -> void:
	arguments = args
	
	print(1)
	get_tree().change_scene_to_file(scene_path)

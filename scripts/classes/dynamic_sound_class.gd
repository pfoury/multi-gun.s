@icon("res://common/icons/SoundIcon.svg")

class_name DynamicSound extends AudioStreamPlayer3D

@export var folder_path := "res://common/sounds/pistol/"


func _ready() -> void:
	queue_free()
	return
	
	#var file_names : Array = DirAccess.get_files_at(folder_path)
	#
	## Setting and playing random audio
	#stream = load(folder_path + file_names.pick_random())
	#play()
	#
	#await finished
	#
	#queue_free()

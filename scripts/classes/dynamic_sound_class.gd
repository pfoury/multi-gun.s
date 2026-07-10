@icon("res://common/icons/SoundIcon.svg")

class_name DynamicSound extends AudioStreamPlayer3D

@export var folder_path := "res://common/sounds/pistol/"


func _ready() -> void:
	var file_count = DirAccess.get_files_at(folder_path).size() / 2
	
	# Choosing which audio to play
	var choose_audio = str(randi_range(1, file_count))
	
	# Setting and playing this specific audio
	stream = load(folder_path + "TEMP_" + choose_audio + ".wav")
	play()


func _on_finished() -> void:
	queue_free()

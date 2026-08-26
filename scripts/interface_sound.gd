extends AudioStreamPlayer

@export var folder_path := "res://common/sounds/pistol/"
@export var valid_extensions: PackedStringArray = ["wav", "ogg", "mp3"]


func _ready() -> void:
	var all_files := DirAccess.get_files_at(folder_path)
	var result : Array
	
	for file_name in all_files:
		var real_name := file_name
		
		if file_name.ends_with(".import"):
			real_name = file_name.trim_suffix(".import")
		
		var ext := real_name.get_extension().to_lower()
		if ext in valid_extensions and real_name not in result:
			result.append(real_name)
	
	var chosen_path = folder_path + result.pick_random()
	var res := load(chosen_path)
	
	if res is AudioStream:
		# Setting and playing random audio
		stream = load(chosen_path)
		play()
		
		await finished
	
	queue_free()

extends RigidBody3D

var sound_effect_scene : PackedScene = load("res://scenes/sounds/sound_effect.tscn")


func _ready() -> void:
	# Creating death sound
	var death_sound_effect = sound_effect_scene.instantiate()
	
	death_sound_effect.folder_path = "res://common/sounds/death/"
	death_sound_effect.bus = "DeathSound"
	
	add_child(death_sound_effect)
	
	await get_tree().create_timer(2.5).timeout
	queue_free()

extends Node

const PORT = 9999
const WEAPON_SCENES = [
	"res://scenes/weapons/pistol.tscn", # Pistol scene
	"res://scenes/weapons/sniper_rifle.tscn", # Sniper rifle scene
	"res://scenes/weapons/assault_rifle.tscn", # Assault rifle scene
	
	"res://scenes/weapons/golden_gun.tscn" # Golden gun scene
]

var arguments : Dictionary = {}


func change_scene_with_arguments(scene_path, args = {}) -> void:
	arguments = args
	
	get_tree().change_scene_to_file(scene_path)

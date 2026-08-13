extends Node

const PORT = 9999
const WEAPON_SCENES = [
	"res://scenes/weapons/pistol.tscn", # Pistol scene
	"res://scenes/weapons/sniper_rifle.tscn", # Sniper rifle scene
	"res://scenes/weapons/assault_rifle.tscn", # Assault rifle scene
	"res://scenes/weapons/deagle.tscn", # Desert eagle scene
	"res://scenes/weapons/ak_67.tscn", # AK67 scene
	
	# Golden Guns
	"res://scenes/weapons/golden_gun.tscn", # Golden gun scene
	"res://scenes/weapons/golden_sniper.tscn" # Golden sniper rifle scene
]

var is_in_game : bool = false
var arguments : Dictionary = {}
var sensitivity : Vector2 = Vector2(2.0, 2.0)
var fov : int = 80

# For settings
var brightness : float = 1.0
var sky_brightness : float = 1.0
var glow : float = 1.3
var is_glow : bool = true
var ssao : String = "Medium (Average)"
var is_ssao : bool = true
var ssil : String = "Medium (Average)"
var is_ssil : bool = true
var is_ssr : bool = false
var is_sdfgi : bool = false


func change_scene_with_arguments(scene_path, args = {}) -> void:
	arguments = args
	
	get_tree().change_scene_to_file(scene_path)

func _update_fov() -> void:
	pass


func _update_brightness() -> void:
	pass


func _update_sky_brightness() -> void:
	pass


func _update_glow() -> void:
	pass


func _update_global_illumination() -> void:
	pass


func _update_SSAO() -> void:
	pass


func _update_SSIL() -> void:
	pass


func _update_SSR() -> void:
	pass


func _update_SDFGI() -> void:
	pass

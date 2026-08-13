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
var ssao_index : int = 2
var is_ssao : bool = true
var ssil_index : int = 2
var is_ssil : bool = true
var is_ssr : bool = false
var is_sdfgi : bool = false


func change_scene_with_arguments(scene_path, args = {}) -> void:
	arguments = args
	
	get_tree().change_scene_to_file(scene_path)


func _update_sensitivity() -> void:
	var main_scene = get_tree().current_scene
	var id = multiplayer.get_unique_id()
	var player = main_scene.players_folder.get_node_or_null(str(id))
	
	if player == null: return
	
	player.first_person_camera.update_mouse_sensitivity(sensitivity)


func _update_fov() -> void:
	var main_scene = get_tree().current_scene
	var id = multiplayer.get_unique_id()
	var player = main_scene.players_folder.get_node_or_null(str(id))
	
	if player == null: return
	
	player.player_fov = fov


func _update_brightness() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	world_env.environment.adjustment_brightness = brightness


func _update_sky_brightness() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	world_env.environment.background_energy_multiplier = sky_brightness


func _update_glow() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	world_env.environment.glow_enabled = is_glow
	
	world_env.environment.glow_strength = glow


func _update_SSAO() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	world_env.environment.ssao_enabled = is_ssao
	
	ProjectSettings.set_setting("rendering/environment/ssao/quality", ssao_index)


func _update_SSIL() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	world_env.environment.ssil_enabled = is_ssao
	
	ProjectSettings.set_setting("rendering/environment/ssil/quality", ssil_index)


func _update_SSR() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	world_env.environment.ssr_enabled = is_ssr

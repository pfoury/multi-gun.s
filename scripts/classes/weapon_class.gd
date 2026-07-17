@icon("res://common/icons/WeaponIcon.svg")

class_name Weapon extends StaticBody3D

# DO NOT FORGET TO PUT WEAPON INTO PLAYER'S MULTIPLAYER SPAWNER

# Standard values for weapon
@export var damage : float = 10.0
@export var fire_speed : float = 0.1
@export var fire_type = ["semi", "burst", "auto"]
@export var reload_speed : float = 1.0
@export var player_speed_multiplier : float = 1.0
@export var push_force : float = 2.0
@export var recoil_strength : float = 1.35
@export var max_ammo : int = 12
@export var is_scopable : bool = true
@export var gun_sound_path : String = "res://common/sounds/pistol/"
# Scenes
@export var muzzle_flash_particles_scene : PackedScene = load("res://scenes/particles/muzzle_flash_particles.tscn")

@onready var animations : AnimationPlayer = $Pivot/AnimationPlayer
@onready var weapon_pivot = $Pivot
@onready var muzzle_flash_pivot = weapon_pivot.find_child("MuzzleFlashPivot")
@onready var fire_timer = $FireTimer
@onready var guns_folder = $".."
@onready var player = $"../.."

var stats : Dictionary = {}
var ammo : int
var player_hud : Node
var is_ready : bool = false
var is_reloading : bool = false
var sound_scene : PackedScene = load("res://scenes/sounds/sound_effect.tscn")

func _ready() -> void:
	ammo = max_ammo
	fire_timer.wait_time = fire_speed
	fire_timer.one_shot = true
	play_equip_animation()


func get_stats() -> Dictionary:
	stats = {
		"damage": damage,
		"fire_speed": fire_speed,
		"fire_type": fire_type,
		"reload_speed": reload_speed,
		"player_speed_multiplier": player_speed_multiplier,
		"recoil_strength": recoil_strength,
		"push_force": push_force,
		"max_ammo": max_ammo
	}
	
	return stats


func set_stats(new_stats) -> void:
	stats = new_stats
	
	var list_of_stats = [
		"damage", "fire_speed", "fire_type", "reload_speed", "player_speed_multiplier", "push_force", "recoil_strength", "max_ammo"
	]
	
	for stat_string in list_of_stats:
		var new_stat = new_stats[stat_string]
		
		set(stat_string, new_stat)
	
	ammo = max_ammo
	fire_timer.wait_time = fire_speed
	
	# Working with player's HUD
	player_hud = player.main_scene.player_hud
	change_ammo_counter()
	change_fire_type()
	player.update_gun_fire_type()
	player.update_weapon_speed_multiplier()
	player_hud.show()


func get_fire_type() -> String:
	return fire_type


func get_weapon_speed_multiplier() -> float:
	return player_speed_multiplier


func is_gun_ready() -> bool:
	var gun_ready = is_ready and (fire_timer.is_stopped() and ammo > 0)
	
	return gun_ready


func is_gun_reloading() -> bool:
	return is_reloading


func change_ammo_counter() -> void:
	player_hud.get_node("AmmoCounter").text = str(ammo) + " / " + str(max_ammo)


func change_fire_type() -> void:
	player_hud.get_node("FireType").text = str(fire_type)


func reload() -> void:
	if ammo == max_ammo: return
	
	player.main_scene.play_reload_animation()
	
	is_reloading = true
	play_reload_animation()
	
	await get_tree().create_timer(reload_speed / 2).timeout
	
	# Checking if current animation is still reloading
	if animations.get_current_animation() == "reload":
		ammo = max_ammo
		change_ammo_counter()
	
	is_reloading = false


func fire() -> void:
	if ammo < 1: return
	ammo -= 1
	
	change_ammo_counter()
	
	fire_timer.start()
	is_reloading = false
	
	player.main_scene.play_shoot_animation()
	
	# Setting up raycast from the player's camera
	var players_cam = player.first_person_camera.global_position
	var to = players_cam + -player.first_person_camera.global_transform.basis.z * 1000.0
	
	# Creating raycast
	var query = PhysicsRayQueryParameters3D.create(players_cam, to)
	query.exclude = [self]
	
	# Getting first intersect with raycast
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result != {}:
		player.main_scene.get_shoot_on(result, multiplayer.get_unique_id())
	
	play_shoot_animation()


#region Animations
func play_reload_animation() -> void:
	animations.play("RESET")
	animations.play("reload")
	
	var reloading_sound = sound_scene.instantiate()
	
	reloading_sound.folder_path = "res://common/sounds/reloading/"
	
	player.sounds_folder.add_child(reloading_sound)


func play_shoot_animation() -> void:
	animations.play("RESET")
	animations.play("shoot")
	
	# Creating muzzle flash
	var muzzle_flash_particles = muzzle_flash_particles_scene.instantiate()
	
	muzzle_flash_particles.transform = muzzle_flash_pivot.global_transform
	
	player.main_scene.particles_folder.add_child(muzzle_flash_particles)
	
	# Adding recoil
	player.camera_pivot.rotation.x += deg_to_rad(recoil_strength)
	
	# Playing shoot sound
	var gun_sound = sound_scene.instantiate()
	
	gun_sound.folder_path = gun_sound_path
	
	player.sounds_folder.add_child(gun_sound)


func play_equip_animation() -> void:
	animations.play("equip")
	await animations.animation_finished
	
	is_ready = true
#endregion

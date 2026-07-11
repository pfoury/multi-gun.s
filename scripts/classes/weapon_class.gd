@icon("res://common/icons/WeaponIcon.svg")

class_name Weapon extends StaticBody3D

# Standard values for weapon
@export var damage : float = 10.0
@export var fire_speed : float = 0.1
@export var fire_type : Array = ["semi", "burst", "auto"]
@export var reload_speed : float = 1.0
@export var player_speed_multiplier : float = 1.0
@export var push_force : float = 2.0
@export var recoil_strength : float = 1.35
@export var max_ammo : int = 12
@export var is_scopable : bool = true
# Scenes
@export var muzzle_flash_particles_scene : PackedScene = load("res://scenes/particles/muzzle_flash_particles.tscn")
@export var shooting_sound_scene : PackedScene = load("res://scenes/sounds/pistol_sound_effect.tscn")

@onready var animations := $AnimationPlayer
@onready var weapon_pivot = $Pivot
@onready var muzzle_flash_pivot = weapon_pivot.find_child("MuzzleFlashPivot")
@onready var fire_timer = $FireTimer
@onready var guns_folder = $".."
@onready var player = $"../.."

var stats : Dictionary = {
	"damage": damage,
	"fire_speed": fire_speed,
	"fire_type": fire_type,
	"reload_speed": reload_speed,
	"player_speed_multiplier": player_speed_multiplier,
	"recoil_strength": recoil_strength,
	"push_force": push_force,
	"max_ammo": max_ammo,
	"is_scopable": is_scopable
}
var ammo : int = max_ammo
var player_hud : Node
var is_reloading : bool = false

func _ready() -> void:
	fire_timer.wait_time = fire_speed
	play_equip_animation()
	
	# Working with player's HUD
	player_hud = player.main_scene.player_hud
	change_ammo_counter()
	change_fire_type()
	player_hud.show()


func get_stats() -> Dictionary:
	return stats


func get_fire_type() -> Array:
	return fire_type


func is_gun_ready() -> bool:
	return (fire_timer.is_stopped() and ammo > 0)


func is_gun_reloading() -> bool:
	return is_reloading


func change_ammo_counter() -> void:
	player_hud.get_node("AmmoCounter").text = str(ammo) + " / " + str(max_ammo)


func change_fire_type() -> void:
	player_hud.get_node("FireType").text = str(fire_type[0])


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
	
	play_shoot_animation()
	
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


#region Animations
func play_reload_animation() -> void:
	animations.play("RESET")
	animations.play("reload")


func play_shoot_animation() -> void:
	animations.play("RESET")
	animations.play("shoot")
	
	# Creating muzzle flash
	var muzzle_flash_particles = muzzle_flash_particles_scene.instantiate()
	
	muzzle_flash_particles.rotation = muzzle_flash_pivot.global_rotation
	muzzle_flash_particles.position = muzzle_flash_pivot.global_position
	
	player.main_scene.particles_folder.add_child(muzzle_flash_particles)
	
	# Adding recoil
	player.camera_pivot.rotation.x += deg_to_rad(recoil_strength)
	
	# Playing shoot sound
	var shooting_sound = shooting_sound_scene.instantiate()
	
	add_child(shooting_sound)


func play_equip_animation() -> void:
	animations.play("equip")
#endregion

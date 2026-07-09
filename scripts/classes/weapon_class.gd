@icon("res://common/icons/WeaponIcon.svg")

class_name Weapon extends StaticBody3D

# Standard values for weapon
@export var damage : float = 10.0
@export var fire_speed : float = 0.2
@export var fire_type : Array = ["semi", "burst", "auto"]
@export var reload_speed : float = 1.0
@export var player_speed_multiplier : float = 1.0
@export var recoil_strength : float = 2.0
@export var max_ammo : int = 12
@export var is_scopable : bool = true

@export var muzzle_flash_particles_scene : PackedScene = load("res://scenes/particles/muzzle_flash_particles.tscn")

@onready var animations = $AnimationPlayer
@onready var weapon_pivot = $Pivot
@onready var muzzle_flash_position = weapon_pivot.find_child("MuzzleFlash")
@onready var fire_timer = $FireTimer
@onready var guns_folder = $".."
@onready var player = $"../.."

var stats: Dictionary = {
	"damage": damage,
	"fire_speed": fire_speed,
	"fire_type": fire_type,
	"reload_speed": reload_speed,
	"player_speed_multiplier": player_speed_multiplier,
	"recoil_strength": recoil_strength,
	"max_ammo": max_ammo,
	"is_scopable": is_scopable
}


func _ready() -> void:
	fire_timer.wait_time = fire_speed
	animations.play("RESET")
	play_equip_animation()


func get_stats() ->  Dictionary:
	return stats


#region Animations
func play_reload_animation() -> void:
	animations.play("reload")


func play_shoot_animation() -> void:
	animations.stop()
	animations.play("shoot")
	
	var muzzle_flash_particles = muzzle_flash_particles_scene.instantiate()
	
	muzzle_flash_particles.rotation = muzzle_flash_position.rotation + Vector3(0, PI, 0)
	
	muzzle_flash_position.add_child(muzzle_flash_particles)


func play_equip_animation() -> void:
	animations.play("equip")
#endregion

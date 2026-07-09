@icon("res://common/icons/WeaponIcon.svg")

class_name Weapon extends StaticBody3D

# Standard values for weapon
@export var damage: float = 10.0
@export var fire_speed: float = 0.2
@export var fire_type: Array = ["semi", "burst", "auto"]
@export var reload_speed: float = 1.0
@export var player_speed_multiplier: float = 1.0
@export var recoil_strength: float = 2.0
@export var max_ammo: int = 12
@export var is_scopable: bool = true

# @onready var animations = 
# @onready var particles_position = 

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
	pass


func get_stats() ->  Dictionary:
	return stats

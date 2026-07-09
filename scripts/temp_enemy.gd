extends StaticBody3D

const LOW_HEALTH_COLOR : Color = Color("676767")
const MAX_HEALTH : float = 150.0

@export var max_health_color : Color = Color.RED
@export var health : float = MAX_HEALTH

@onready var enemy_mesh := $Pivot/MeshInstance3D

var unique_mat


func _ready() -> void:
	unique_mat = enemy_mesh.get_active_material(0).duplicate()
	enemy_mesh.set_surface_override_material(0, unique_mat)
	
	change_color()


func get_damaged(dmg: float) -> void:
	health -= dmg
	if health <= 0:
		die()
	else:
		change_color()


func change_color() -> void:
	print(health, MAX_HEALTH)
	var color_difference = 1.0 - (health / MAX_HEALTH)
	unique_mat.albedo_color = max_health_color.lerp(LOW_HEALTH_COLOR, color_difference)


func die() -> void:
	pass

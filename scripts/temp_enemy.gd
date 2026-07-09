extends StaticBody3D

const END_COLOR : Color = "DIM_GRAY"
const MAX_HEALTH : float = 150.0

@export var start_color : Color = "Red"

@onready var mesh := $Pivot/MeshInstance3D


var health : float = MAX_HEALTH
var mesh_color : Color

func _ready() -> void:
	mesh_color = mesh.mesh.material.albedo_color


func get_damaged(dmg: float) -> void:
	health -= dmg
	if health <= 0:
		die()
	else:
		change_color()


func change_color() -> void:
	var color_difference = 1.0 - (health / MAX_HEALTH)
	mesh_color = start_color.lerp(END_COLOR, color_difference)


func die() -> void:
	pass

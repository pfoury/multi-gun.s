extends StaticBody3D

const LOW_HEALTH_COLOR : Color = Color("676767")
const MAX_HEALTH : float = 150.0

@export var max_health_color : Color = Color.RED
@export var health : float = MAX_HEALTH
@export var corpse_scene : PackedScene = load("res://scenes/corpse.tscn")

@onready var enemy_mesh := $Pivot/MeshInstance3D
@onready var main_scene := get_tree().current_scene

var unique_mat


func _ready() -> void:
	unique_mat = enemy_mesh.get_active_material(0).duplicate()
	enemy_mesh.set_surface_override_material(0, unique_mat)
	
	change_color()


func get_damaged(data) -> void: # Getting called with rpc (everyone sees it)
	health -= data["damage"]
	if health <= 0:
		die(data)
	else:
		change_color()


func change_color() -> void:
	var color_difference = 1.0 - (health / MAX_HEALTH)
	unique_mat.albedo_color = max_health_color.lerp(LOW_HEALTH_COLOR, color_difference)


func die(data):
	var corpse = corpse_scene.instantiate()
	
	corpse.global_transform = global_transform
	main_scene.objects_folder.add_child(corpse)
	
	var push_dir = -data["normal"]
	
	var push_force = data["push_force"]
	
	corpse.apply_impulse(Vector3(0, 5, 0) + push_dir * push_force * 6)
	corpse.apply_torque_impulse(
		Vector3(
			randi_range(-2, 2),
			randi_range(-2, 2),
			randi_range(-2, 2)
		)
	)
	
	queue_free()

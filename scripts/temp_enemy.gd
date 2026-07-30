extends RigidBody3D

const LOW_HEALTH_COLOR : Color = Color("676767")
const MAX_HEALTH : float = 100.0

@export var max_health_color : Color = Color.RED
@export var health : float = MAX_HEALTH
@export var corpse_scene : PackedScene = load("res://scenes/corpse.tscn")
@export var health_regeneration_particles_scene : PackedScene = load("res://scenes/particles/health_regeneration_particles.tscn")
@export var is_regen_timer_ready : bool = true

@onready var enemy_mesh : Node = $Pivot/MeshInstance3D
@onready var main_scene : Node = get_tree().current_scene
@onready var regen_timer : Node = $RegenTimer

var unique_mat : Material


func _ready() -> void:
	unique_mat = enemy_mesh.get_active_material(0).duplicate()
	enemy_mesh.set_surface_override_material(0, unique_mat)
	
	change_color()


func _process(_delta: float) -> void:
	if health < MAX_HEALTH and is_regen_timer_ready:
		is_regen_timer_ready = false
		regen_timer.start()


@rpc("reliable", "any_peer", "call_local")
func damage(data) -> void: # Getting called with rpc (everyone sees it)
	health -= data["damage"]
	regen_timer.start()
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
	main_scene.objects_folder.add_child(corpse, true)
	
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
	
	var peer_id = data["peer_id"]
	
	if multiplayer.is_server():
		Client.add_point.rpc(peer_id)
	
	if multiplayer.get_unique_id() == peer_id:
		var player = main_scene.players_folder.get_node(str(peer_id))
		
		player.play_kill_sound()
	
	queue_free()


func _on_regen_timer_timeout() -> void:
	is_regen_timer_ready = true
	
	health += MAX_HEALTH / 10.0
	if health > MAX_HEALTH: health = MAX_HEALTH
	
	change_color()
	
	# Creating health regeneration particles
	if randi_range(1, 2) == 2: # Creating with 50% chance
		var health_regeneration_particles = health_regeneration_particles_scene.instantiate()
		
		health_regeneration_particles.position = global_position
		
		main_scene.particles_folder.add_child(health_regeneration_particles)

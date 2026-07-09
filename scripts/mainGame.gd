extends Node

const PORT = 9999

@export var player_scene : PackedScene = load("res://scenes/player.tscn")
@export var testobject_scene : PackedScene = load("res://scenes/temp/temp_enemy.tscn")
@export var pistol_scene : PackedScene = load("res://scenes/weapons/pistol.tscn")
@export var blood_flesh_particles_scene : PackedScene = load("res://scenes/particles/blood_flesh_particles.tscn")
@export var dust_hit_particles_scene : PackedScene = load("res://scenes/particles/dust_hit_particles.tscn")

# Folders
@onready var players_folder := $Players
@onready var objects_folder := $Objects
@onready var particles_folder := $Particles
# Menu
@onready var main_menu_gui := $CanvasLayer/MainMenu

var enet_peer = ENetMultiplayerPeer.new()


func _ready() -> void:
	pass


func _on_host_pressed() -> void:
	main_menu_gui.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())


func _on_join_pressed() -> void:
	main_menu_gui.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id) -> void:
	var player = player_scene.instantiate()
	
	player.name = str(peer_id)
	
	players_folder.add_child(player)
	print("меня звать ", peer_id, " и я был создан!")
	rpc("create_weapon", peer_id)


func add_test_object(result) -> void:
	rpc("receive_creation_of_test_object", result)


func register_shoot(peer_id) -> void:
	rpc("receive_player_shoot_animation", peer_id)


func get_shoot_on(data, peer_id) -> void:
	var result : Dictionary = {
		"instance_id": data["collider_id"],
		"instance_name": instance_from_id(data["collider_id"]).name,
		"peer_id": peer_id,
		"position": data["position"],
		"normal": data["normal"],
		"damage": 0.0
	}
	
	var particles : Node
	
	# Deciding what particles to create
	if instance_from_id(result["instance_id"]).is_in_group("enemy"):
		particles = blood_flesh_particles_scene.instantiate()
		
		var player = players_folder.get_node(str(peer_id))
		
		var stats = player.guns_folder.get_node("gun").get_stats()
		var damage = stats["damage"]
		
		result["damage"] = damage
		
		rpc("receive_damage_enemy", result)
	else:
		particles = dust_hit_particles_scene.instantiate()
	
	if particles != null:
		# Creating particles
		var normal = data["normal"]
			
		var tangent = normal.cross(Vector3.UP)
		if tangent.length_squared() < 0.0001:
			tangent = normal.cross(Vector3.RIGHT)
			
		tangent = tangent.normalized()
			
		particles.look_at_from_position(particles.position, particles.position - data["normal"], tangent)
		particles.position = data["position"]
			
		particles_folder.add_child(particles)


#region Rpcs
@rpc("call_local", "any_peer", "reliable") # Creates object ON ALL clients
func receive_creation_of_test_object(data) -> void: # REWORK naming test object
	var testobject = testobject_scene.instantiate()
		
	if data != {}:
		testobject.position = data["position"] + Vector3(0, 1, 0)
		
		testobject.name = "testObject" + str(objects_folder.get_child_count())
		
		objects_folder.add_child(testobject)


@rpc("call_local", "any_peer", "reliable") # Creates object ON ALL clients
func receive_damage_enemy(data) -> void:
	var enemy = objects_folder.get_node(str(data["instance_name"]))
	
	if enemy != null:
		enemy.get_damaged(data["damage"])


@rpc("call_local", "any_peer", "unreliable") # Creates object ON ALL clients, but package may be lost
func receive_player_shoot_animation(data):
	if data == multiplayer.get_unique_id():
		return
	
	var player = players_folder.get_node(str(data))
	
	player.guns_folder.get_node("gun").play_shoot_animation()


@rpc("call_local", "any_peer", "reliable") # Creates object ON ALL clients
func create_weapon(data) -> void:
	var player = players_folder.get_node(str(data))
	var pistol = pistol_scene.instantiate()
	
	pistol.name = "gun"
	
	player.guns_folder.add_child(pistol)
#endregion

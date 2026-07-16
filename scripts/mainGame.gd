extends Node

const PORT = 9999
const WEAPON_SCENES = [
	"res://scenes/weapons/pistol.tscn", # Pistol scene
	"res://scenes/weapons/sniper_rifle.tscn", # Sniper rifle scene
	"res://scenes/weapons/assault_rifle.tscn" # Assault rifle scene
]

@export var player_scene : PackedScene = load("res://scenes/player.tscn")
@export var testobject_scene : PackedScene = load("res://scenes/temp/temp_enemy.tscn")
@export var gun_scene : PackedScene
@export var blood_flesh_particles_scene : PackedScene = load("res://scenes/particles/blood_flesh_particles.tscn")
@export var dust_hit_particles_scene : PackedScene = load("res://scenes/particles/dust_hit_particles.tscn")
@export var hit_indicator_particles_scene : PackedScene = load("res://scenes/particles/hit_indicator_particles.tscn")
# For Multiplayer Synchronizer
@export var amount_of_weapons : int = 16
@export var weapon_pool : Array = []
@export var player_list : Dictionary = {}
@export var player_color_list : Dictionary = {}
@export var scoreboard : Dictionary = {}

@onready var test_object_spawner : MultiplayerSpawner = $TestObjectsSpawner
@onready var update_timer : Timer = $UpdateTimer
# Folders
@onready var players_folder := $Players
@onready var objects_folder := $Objects
@onready var particles_folder := $Particles
# HUD
@onready var main_menu_gui := $HUD/MainMenu
@onready var player_hud := $HUD/PlayerHUD

var enet_peer = ENetMultiplayerPeer.new()
var weapon_craziness : float = 20.0


func _ready() -> void:
	player_hud.hide()
	main_menu_gui.show()


func _on_host_pressed() -> void:
	main_menu_gui.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(add_player)
	
	create_weapon_pool()
	add_player(multiplayer.get_unique_id())
	
	update_timer.start()


func _on_join_pressed() -> void:
	main_menu_gui.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer


#func _on_update_timer_timeout() -> void:
	#if multiplayer.is_server:
		#rpc("receive_global_update")
		#update_timer.start()


func add_player(peer_id) -> void:
	var random_color : Color = Color(randf(), randf(), randf())
	
	# Adding to dictionaries
	player_list[peer_id] = "nickname" # Player's nickname
	player_color_list[peer_id] = random_color
	scoreboard[peer_id] = 0 # Player's initial score
	
	var player = player_scene.instantiate()
	
	player.name = str(peer_id)
	
	players_folder.add_child(player)
	
	print("меня звать ", peer_id, " и я был создан!")
	
	if peer_id == 1:
		print(player_color_list[peer_id])
		create_weapon()
	else:
		var result : Dictionary = {
			"weapon_pool": weapon_pool,
			"player_list": player_list,
			"scoreboard": scoreboard,
			"amount_of_weapons": amount_of_weapons,
			"player_color_list": player_color_list
		}
		rpc_id(peer_id, "load_client", result)


func add_test_object(result) -> void:
	rpc_id(1, "receive_creation_of_test_object", result)
	
	if multiplayer.get_unique_id() != 1:
		receive_creation_of_test_object(result)


func add_point(peer_id) -> void:
	rpc("receive_add_point", peer_id)


func play_shoot_animation() -> void:
	rpc("receive_player_shoot_animation", multiplayer.get_unique_id())


func play_reload_animation() -> void:
	rpc("receive_player_reload_animation", multiplayer.get_unique_id())


func get_shoot_on(data, peer_id) -> void:
	var result : Dictionary = {
		"instance_id": data["collider_id"],
		"instance_name": instance_from_id(data["collider_id"]).name,
		"peer_id": peer_id,
		"position": data["position"],
		"normal": data["normal"],
		"damage": 0.0,
		"push_force": 0.0
	}
	
	var particles : Node
	
	# Deciding what particles to create
	if instance_from_id(result["instance_id"]).is_in_group("enemy"):
		particles = blood_flesh_particles_scene.instantiate()
		
		var player = players_folder.get_node(str(peer_id))
		
		var stats = player.guns_folder.get_node("Gun").get_stats()
		
		if stats == {}: return # Checking if stats are generated at all
		
		var push_force = stats["push_force"]
		
		result["push_force"] = push_force
		
		if not instance_from_id(result["instance_id"]).is_in_group("corpse"):
			var damage = stats["damage"]
			result["damage"] = damage
			
			if instance_from_id(result["instance_id"]).is_in_group("player"):
				rpc("receive_damage_player", result)
			else:
				rpc("receive_damage_test_enemy", result)
			
			var hit_indicator_particles = hit_indicator_particles_scene.instantiate()
			
			hit_indicator_particles.position = result["position"]
			
			particles_folder.add_child(hit_indicator_particles)
			
			# Getting numbers node to change text on it
			var hit_indicator_numbers = hit_indicator_particles.get_node("Numbers")
			
			hit_indicator_numbers.draw_pass_1.text = str(int(damage))
		else:
			rpc("receive_corpse_push", result)
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


func create_weapon_pool() -> void:
	# Creating weapon pool via randi_range
	for count in range(amount_of_weapons):
		var random_pick = randi_range(1, WEAPON_SCENES.size())
		
		weapon_pool.append(random_pick - 1)


#func update_players_color() -> void:
	#var players = players_folder.get_children()
	#
	#for player in players:
		#var peer_id = int(player.name)
		#player.set_new_color(player_color_list[peer_id])


#region Rpcs
@rpc("call_local", "any_peer", "reliable") # Creates object ON ALL clients
func receive_creation_of_test_object(data) -> void: # REWORK naming test object
	if data != {}:
		#print("Я был создан игроком ", multiplayer.get_remote_sender_id(), " и был вызван у ", multiplayer.get_unique_id())
		var testobject = testobject_scene.instantiate()
		var new_name = str(objects_folder.get_child_count() + 1)
		
		testobject.position = data["position"] + Vector3(0.0, 1.0, 0.0)
		
		testobject.name = "testObject" + new_name
		
		objects_folder.add_child(testobject, true)


@rpc("call_local", "any_peer", "reliable") # Creates object ON ALL clients
func receive_damage_test_enemy(data) -> void:
	var enemy = objects_folder.get_node(str(data["instance_name"]))
	
	if enemy != null:
		enemy.get_damaged(data)


@rpc("call_local", "any_peer", "reliable")
func receive_damage_player(data) -> void:
	var player = players_folder.get_node(str(data["instance_name"]))
	
	if player != null:
		player.get_damaged(data)


@rpc("call_local", "any_peer", "reliable") # Creates object ON ALL clients
func receive_corpse_push(data) -> void:
	var corpse = objects_folder.get_node(str(data["instance_name"]))
	
	if corpse != null:
		var push_dir = -data["normal"]
	
		var push_force = data["push_force"]
		
		corpse.apply_impulse(Vector3(0, 5, 0) + push_dir * push_force * 2)
		corpse.apply_torque_impulse(
			Vector3(
				randi_range(-2, 2),
				randi_range(-2, 2),
				randi_range(-2, 2)
			)
		)


@rpc("call_local", "any_peer", "unreliable") # Creates object ON ALL clients, but package may be lost
func receive_player_shoot_animation(data) -> void:
	if data == multiplayer.get_unique_id():
		return
	
	var player = players_folder.get_node(str(data))
	
	player.guns_folder.get_node("Gun").play_shoot_animation()


@rpc("call_local", "any_peer", "unreliable") # Creates object ON ALL clients, but package may be lost
func receive_player_reload_animation(data) -> void:
	if data == multiplayer.get_unique_id():
		return
	
	var player = players_folder.get_node(str(data))
	
	player.guns_folder.get_node("Gun").play_reload_animation()


@rpc("call_local", "any_peer", "reliable") # Gets called ON ALL CLIENTS
func receive_add_point(data) -> void:
	scoreboard[data] += 1
	
	if scoreboard[data] >= amount_of_weapons:
		print("ИГРОК ", data, " ПОБЕДИЛ!!!")
		return
	
	if data == multiplayer.get_unique_id():
		print(scoreboard)
		
		var player : Node = players_folder.get_node(str(multiplayer.get_unique_id()))
		var guns : Node = player.guns_folder
		var gun : Node = guns.get_node("Gun")
		
		guns.remove_child(gun)
		gun.queue_free()
		
		while player.guns_folder.has_node("Gun"):
			await get_tree().process_frame
		
		rpc("create_weapon")


@rpc("authority", "call_remote", "reliable")
func receive_new_weapon_stats(data) -> void:
	var peer_id = multiplayer.get_unique_id()
	
	var player : Node = players_folder.get_node(str(peer_id))
	var guns : Node = player.guns_folder
	var gun : Node = guns.get_node("Gun")
	
	gun.set_stats(data)


@rpc("authority", "call_remote", "reliable") # Getting data for new player
func load_client(data) -> void:
	weapon_pool = data["weapon_pool"]
	player_list = data["player_list"]
	scoreboard = data["scoreboard"]
	amount_of_weapons = data["amount_of_weapons"]
	player_color_list = data["player_color_list"]
	
	rpc("create_weapon")


@rpc("call_local", "any_peer", "reliable") # Generating new stats for the player
func generate_new_weapon_stats(data) -> void:
	var player : Node = players_folder.get_node(str(data))
	var guns : Node = player.guns_folder
	var gun : Node = guns.get_node("Gun")
	
	# Getting stats
	var weapon_stats = await gun.get_stats()
	
	var list_of_stats = [
		"damage", "fire_speed", "fire_type", "reload_speed", "player_speed_multiplier", "push_force", "recoil_strength", "max_ammo"
	]
	
	# Generating new stats
	for stat_string in list_of_stats:
		var stat = weapon_stats[stat_string]
		
		# Generating random scale for stat
		var rand_min : float = 1.0 - weapon_craziness / 100
		var rand_max : float = 1.0 + weapon_craziness / 100
		
		var randomness = randf_range(rand_min, rand_max)
		
		if stat is float:
			stat = roundf(stat * randomness * 100) / 100
		elif stat is int:
			stat = round(stat * randomness)
		elif stat is Array:
			stat = stat.pick_random()
		
		weapon_stats[stat_string] = stat
	
	# Giving back new stats
	if int(player.name) != 1:
		rpc_id(data, "receive_new_weapon_stats", weapon_stats)
	else:
		receive_new_weapon_stats(weapon_stats)


@rpc("call_local", "any_peer", "reliable") # Creates object ON ALL clients
func create_weapon() -> void:
	var peer_id = multiplayer.get_unique_id()
	
	var player = players_folder.get_node(str(peer_id))
	
	if not player.guns_folder.get_child_count():
		var weapon_number = scoreboard[peer_id]
		
		var gun = load(WEAPON_SCENES[weapon_pool[weapon_number]]).instantiate()
		
		gun.name = "Gun"
		
		player.guns_folder.add_child(gun, true)
		
		if multiplayer.get_unique_id() == multiplayer.get_remote_sender_id() or multiplayer.is_server():
			if player.name != "1":
				rpc_id(1, "generate_new_weapon_stats", peer_id)
			else:
				generate_new_weapon_stats(peer_id)
#endregion

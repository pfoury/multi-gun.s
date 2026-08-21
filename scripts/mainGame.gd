extends Node

# For Multiplayer Synchronizer
@export var amount_of_weapons : int = 50
@export var weapon_pool : Array = []
@export var player_list : Dictionary = {}
@export var player_color_list : Dictionary = {}
@export var scoreboard : Dictionary = {}

@onready var test_object_spawner : MultiplayerSpawner = $TestObjectsSpawner
# Folders
@onready var players_folder : Node3D = $Players
@onready var objects_folder : Node3D = $Objects
@onready var particles_folder : Node3D = $Particles
@onready var spawn_points_folder : Node3D = $SpawnPoints
# HUD
@onready var player_hud := $HUD/PlayerHUD
@onready var kill_feed := $HUD/PlayerHUD/KillFeed
@onready var statistics := $HUD/PlayerHUD/Statistics
@onready var top_players: HBoxContainer = $HUD/PlayerHUD/TopHUD/TopPlayers
@onready var escape_menu: Control = $HUD/PlayerHUD/EscapeMenu

var enet_peer = ENetMultiplayerPeer.new()
var weapon_craziness : float = 20.0
var gun_scene : PackedScene
var player_scene : PackedScene = load("res://scenes/player.tscn")
var testobject_scene : PackedScene = load("res://scenes/temp/temp_enemy.tscn")
var kill_log_scene : PackedScene = load("res://scenes/HUD/kill_log.tscn")
var player_icon_scene : PackedScene = load("res://scenes/HUD/player_icon.tscn")


func _ready() -> void:
	Client.change_main_scene()
	Server.change_main_scene()
	
	await get_tree().process_frame
	
	Global.is_in_game = true
	
	var args : Dictionary = {
		"username": Global.arguments["username"],
		"color": Global.arguments["color"]
	}
	
	if Global.arguments.has("ip"):
		args["ip"] = Global.arguments["ip"]
	else:
		args["ip"] = "localhost"
	
	if Global.arguments.has("peer"):
		match Global.arguments["peer"]:
			"host":
				enet_peer.create_server(Global.PORT)
				multiplayer.multiplayer_peer = enet_peer
				
				multiplayer.peer_disconnected.connect(remove_player)
				multiplayer.server_disconnected.connect(to_menu)
				
				Server.create_weapon_pool()
				Server.create_global_timer()
				
				args["peer_id"] = multiplayer.get_unique_id()
				Server.add_player(args)
			"client":
				enet_peer.create_client(args["ip"], Global.PORT)
				multiplayer.multiplayer_peer = enet_peer
				
				args["peer_id"] = multiplayer.get_unique_id()
				
				var count : int = 0
				
				while multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
					await get_tree().process_frame
					
					count += 1
					if count >= 1000:
						print("Huh.. Seems weird.. Maybe game is not hosted?")
						get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
						return
				
				Server.rpc_id(1, "receive_new_player", args)
		Global.arguments.clear()
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _process(_delta: float) -> void:
	# FPS counter
	var fps_label = statistics.get_node_or_null("FPSLabel")
	
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())


func remove_player(peer_id) -> void:
	# Erasing player
	player_list.erase(peer_id)
	scoreboard.erase(peer_id)
	player_color_list.erase(peer_id)
	
	var player = players_folder.get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
	
	Client.rpc("receive_global_update")


func to_menu() -> void:
	if !multiplayer.connected_to_server: return


func play_shoot_animation() -> void: ## REWORKED
	if !multiplayer.is_server():
		Server.rpc_id(1, "shoot_animation", multiplayer.get_unique_id())
	else:
		Client.rpc("receive_shoot_animation", multiplayer.get_unique_id())

func play_reload_animation() -> void: ## REWORKED
	if !multiplayer.is_server():
		Server.rpc_id(1, "reload_animation", multiplayer.get_unique_id())
	else:
		Client.rpc("receive_reload_animation", multiplayer.get_unique_id())

func damage_player(result) -> void: ## REWORKED
	if !multiplayer.is_server():
		Server.rpc_id(1, "damage_player", result)
	else:
		Server.damage_player(result)

func damage_test_enemy(result) -> void: ## REWORKED
	if !multiplayer.is_server():
		Server.rpc_id(1, "damage_test_enemy", result)
	else:
		Server.damage_test_enemy(result)

func push_corpse(result) -> void: ## REWORKED
	if !multiplayer.is_server():
		Server.rpc_id(1, "push_corpse", result)
	else:
		Server.push_corpse(result)

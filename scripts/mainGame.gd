extends Node

const PORT = 9999

@export var player_scene : PackedScene

# Folders
@onready var players_folder := $Players
@onready var objects_folder := $Objects
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


func add_player(peer_id):
	var player = player_scene.instantiate()
	
	player.name = str(peer_id)
	
	players_folder.add_child(player)

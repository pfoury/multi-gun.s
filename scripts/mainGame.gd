extends Node

const PORT = 9999

@export var player_scene : PackedScene
@export var testobject_scene : PackedScene
@export var pistol_scene : PackedScene

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
	print("меня звать ", peer_id, " и я был создан!")
	rpc("create_weapon", peer_id)


func add_test_object(result) -> void:
	rpc("receive_creation_of_test_object", result)


@rpc("call_local", "any_peer", "reliable") # Creates object ON ALL clients
func receive_creation_of_test_object(data) -> void:
	var testobject = testobject_scene.instantiate()
		
	if data != {}:
		testobject.position = data["position"]
			
		var normal = data["normal"]
		
		var tangent = normal.cross(Vector3.UP)
		if tangent.length_squared() < 0.0001:
			tangent = normal.cross(Vector3.RIGHT)

		tangent = tangent.normalized()
		
		testobject.look_at_from_position(testobject.position, testobject.position - data["normal"], tangent)
		testobject.name = "testObject" + str(objects_folder.get_child_count())
		
		objects_folder.add_child(testobject)

@rpc("call_local", "any_peer", "reliable")
func create_weapon(data) -> void:
	print("создается пушка..")
	print(data)
	var player = players_folder.get_node(str(data))
	var pistol = pistol_scene.instantiate()
	
	print(players_folder.get_children())
	player.guns_folder.add_child(pistol)

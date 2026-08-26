extends Node

var main : Node
var player_scene : PackedScene = load("res://scenes/player.tscn")
var testobject_scene : PackedScene = load("res://scenes/temp/temp_enemy.tscn")
var kill_log_scene : PackedScene = load("res://scenes/HUD/kill_log.tscn")
var player_icon_scene : PackedScene = load("res://scenes/HUD/player_icon.tscn")


func change_main_scene():
	main = get_tree().current_scene


func list_of_updates() -> void: # Call this function to update everything player needs
	update_players()
	update_top_players()


func update_players() -> void:
	var players = main.players_folder.get_children()
	
	for player in players:
		player.change_color()


func update_top_players() -> void:
	if main.player_list == {}: return
	
	var player_count = len(main.player_list)
	
	# If necessary, adding new player icons
	if main.top_players.get_child_count() == 0 or (main.top_players.get_child_count() < 6 and player_count > main.top_players.get_child_count()):
		while main.top_players.get_child_count() < 6 and player_count > main.top_players.get_child_count():
			var player_icon = player_icon_scene.instantiate()
			
			main.top_players.add_child(player_icon)
	
	# If necessary, removing old player icons
	while player_count < main.top_players.get_child_count():
		var random_player_icon = main.top_players.get_children().pick_random()
		
		main.top_players.remove_child(random_player_icon)
		random_player_icon.queue_free()
		
		await get_tree().process_frame
	
	var sorted_players = main.scoreboard.keys()
	
	sorted_players.sort_custom(func(a, b):
		return main.scoreboard[a] > main.scoreboard[b]
	)
	
	
	var player_icons = main.top_players.get_children()
	var index : int = 0
	
	# Changing icons
	for player in sorted_players:
		if index == 6: break
		
		var player_icon = player_icons[index]
		
		if index == 0:
			player_icon.offset_transform_scale = Vector2(1.3, 1.3)
		
		var icon_color : TextureRect = player_icon.get_node("PlayerColor")
		var icon_outline : TextureRect = player_icon.get_node("PlayerOutline")
		var score : Label = player_icon.get_node("Score")
		
		var player_color = main.player_color_list[player]
		
		icon_color.self_modulate.r = player_color.r
		icon_color.self_modulate.g = player_color.g
		icon_color.self_modulate.b = player_color.b
		
		if multiplayer.get_unique_id() == player:
			icon_outline.texture.load_path = "res://.godot/imported/CurrentPlayer.png-e86da933f90855c9e91ed4a290d223bb.ctex"
		else:
			icon_outline.texture.load_path = "res://.godot/imported/DifferentPlayer.png-e7b79b34a597570bdd2c7f8599b5e392.ctex"
		
		score.text = str(main.scoreboard[player])
		
		index += 1


func quit_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
	Global.is_in_game = false


func add_test_object(result) -> void:
	Server.rpc_id(1, "receive_creation_of_test_object", result)
	
	if multiplayer.get_unique_id() != 1:
		Server.receive_creation_of_test_object(result)


#region Rpcs
@rpc("call_local", "authority", "reliable") # Creates object ON ALL clients, but package may be lost
func receive_shoot_animation(data) -> void:
	if data == multiplayer.get_unique_id():
		return
	
	var player = main.players_folder.get_node(str(data))
	
	player.guns_folder.get_node("Gun").play_shoot_animation()


@rpc("call_local", "authority", "unreliable") # Creates object ON ALL clients, but package may be lost
func receive_reload_animation(data) -> void:
	if data == multiplayer.get_unique_id():
		return
	
	var player = main.players_folder.get_node(str(data))
	
	player.guns_folder.get_node("Gun").play_reload_animation()


@rpc("authority", "call_remote", "reliable")
func receive_new_weapon_stats(data) -> void:
	var peer_id = multiplayer.get_unique_id()
	
	var player : Node = main.players_folder.get_node(str(peer_id))
	var guns : Node = player.guns_folder
	var gun : Node = guns.get_node("Gun")
	
	while gun == null:
		await get_tree().process_frame
	
	gun.set_stats(data)


@rpc("authority", "call_local", "reliable")
func receive_global_update() -> void:
	list_of_updates()


@rpc("authority", "call_remote", "reliable") # Getting data for new player
func load_client(data) -> void:
	main.weapon_pool = data["weapon_pool"]
	main.player_list = data["player_list"]
	main.scoreboard = data["scoreboard"]
	main.amount_of_weapons = data["amount_of_weapons"]
	main.player_color_list = data["player_color_list"]
	main.gm = data["gm"]
	
	var gm_label = main.gamemode_container.get_node_or_null("GMLabel")
	if gm_label != null: gm_label.text = main.gm
	
	if main.gm != "Randomizer": rpc("create_weapon", data["peer_id"])


@rpc("call_local", "any_peer", "reliable")
func create_kill_log(killer_id, victim_id) -> void:
	# Does player have player list?
	if main.player_list == {}: return
	# Are IDs in the players' list?
	if killer_id not in main.player_list or victim_id not in main.player_list: return 
	
	# Creating kill log
	var kill_log = kill_log_scene.instantiate()
	
	main.kill_feed.add_child(kill_log)
	
	# Getting children :smirk:
	var killer_label = kill_log.get_node("KillerLabel")
	var victim_label = kill_log.get_node("VictimLabel")
	
	# Changing their text to usernames
	killer_label.text = main.player_list[killer_id]
	victim_label.text = main.player_list[victim_id]
	
	# That's all, my folks!


@rpc("call_local", "any_peer", "reliable")
func add_point(data) -> void:
	main.scoreboard[data] += 1
	
	if multiplayer.is_server() and main.scoreboard[data] >= main.amount_of_weapons:
		print("ИГРОК ", data, " ПОБЕДИЛ!!!")
		end_game.rpc(data)
	
	if main.gm == "Randomizer": return
	
	replace_gun(data)


@rpc("call_local", "any_peer", "reliable")
func end_game(winner_peer_id) -> void:
	delete_gun.rpc()
	var player = main.players_folder.get_node_or_null(str(winner_peer_id))
	
	# End screen
	var end_screen_animations = main.end_screen.get_node("AnimationPlayer")
	end_screen_animations.play("play")
	
	var end_screen_pc = main.end_screen.get_node("PC")
	
	var player_icon = end_screen_pc.get_node("HBC").get_node("PlayerIcon")
	var player_icon_color = player_icon.get_node("PlayerColor")
	
	var player_color = main.player_color_list[winner_peer_id]
	
	player_icon_color.self_modulate.r = player_color.r
	player_icon_color.self_modulate.g = player_color.g
	player_icon_color.self_modulate.b = player_color.b
	
	player_icon.get_node("Score").hide()
	
	end_screen_pc.self_modulate.r = player_color.r
	end_screen_pc.self_modulate.g = player_color.g
	end_screen_pc.self_modulate.b = player_color.b
	
	var winner_username = end_screen_pc.get_node("HBC").get_node("VBC").get_node("VBC").get_node("PlayerUsername")
	winner_username.text = main.player_list[winner_peer_id]
	
	# Sound
	var sound_scene = load("res://scenes/sounds/sound_effect.tscn").instantiate()
	sound_scene.bus = "EndScreen"
	
	if winner_peer_id == multiplayer.get_unique_id():
		sound_scene.folder_path = "res://common/sounds/end_sounds/victory/"
	else:
		sound_scene.folder_path = "res://common/sounds/end_sounds/defeat/"
	
	player.sounds_folder.add_child(sound_scene)


@rpc("call_local", "any_peer", "reliable")
func delete_gun() -> void:
	var peer_id = multiplayer.get_unique_id()
	
	var player = main.players_folder.get_node(str(peer_id))
	var guns : Node3D = player.guns_folder
	var gun = guns.get_node_or_null("Gun")
	
	if gun:
		guns.remove_child(gun)
		gun.queue_free()
		
		while player.guns_folder.has_node("Gun"):
			await get_tree().process_frame


@rpc("call_local", "any_peer", "reliable")
func replace_gun(peer_id : int = multiplayer.get_unique_id()) -> void:
	if multiplayer.get_unique_id() == peer_id:
		delete_gun()
	create_weapon.rpc(peer_id)


@rpc("call_local", "any_peer", "reliable")
func create_weapon(peer_id) -> void:
	if multiplayer.get_unique_id() != peer_id: return
	
	var player = main.players_folder.get_node(str(peer_id))
	var guns : Node3D = player.guns_folder
	var gun = guns.get_node_or_null("Gun")
	
	if gun == null and peer_id in main.scoreboard and main.scoreboard[peer_id] < len(main.weapon_pool):
		var weapon_number = main.scoreboard[peer_id]
		
		var new_gun
		if main.gm != "Randomizer":
			new_gun = load(Global.WEAPON_SCENES[main.weapon_pool[weapon_number]]).instantiate()
		else:
			new_gun = load(Global.WEAPON_SCENES[randi_range(0, len(Global.WEAPON_SCENES) - 1)]).instantiate()
		
		new_gun.name = "Gun"
		
		player.guns_folder.add_child(new_gun, true)
		
		if multiplayer.get_unique_id() == peer_id:
			if multiplayer.get_unique_id() == 1:
				Standard.generate_new_weapon_stats(1)
			else:
				Standard.generate_new_weapon_stats.rpc_id(1, peer_id)

#endregion

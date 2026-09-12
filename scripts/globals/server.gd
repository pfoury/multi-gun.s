extends Node

var main : Node = null
var update_timer : Timer
var corpse_scene : PackedScene = preload("res://scenes/corpse.tscn")
var sound_scene : PackedScene = preload("res://scenes/sounds/sound_effect.tscn")
var dead_players : Array = []


func is_server() -> bool:
	return multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and multiplayer.is_server()


func change_main_scene() -> void:
	await get_tree().scene_changed
	
	main = get_tree().current_scene


func add_player(data) -> void:
	var peer_id = data["peer_id"]
	
	# Adding to dictionaries
	main.player_list[peer_id] = data["username"] # Player's nickname
	main.player_color_list[peer_id] = data["color"] # Player's color
	main.player_accessories_face[peer_id] = data["face"] # Player's face accessory
	main.player_accessories_hat[peer_id] = data["hat"] # Player's hat accessory
	main.player_quotes[peer_id] = data["quote"] # Player's quote
	main.scoreboard[peer_id] = 0 # Player's initial score
	
	var player = Client.player_scene.instantiate()
	
	player.name = str(peer_id)
	
	main.players_folder.add_child(player)
	
	player.change_color()
	
	if peer_id == 1:
		main.amount_of_weapons = Global.arguments["scoregoal"]
		Client.create_weapon(1)
	else:
		var result : Dictionary = {
			"weapon_pool": main.weapon_pool,
			"player_list": main.player_list,
			"scoreboard": main.scoreboard,
			"amount_of_weapons": main.amount_of_weapons,
			"player_color_list": main.player_color_list,
			"player_accessories_face": main.player_accessories_face,
			"player_accessories_hat": main.player_accessories_hat,
			"player_quotes": main.player_quotes,
			"peer_id": peer_id,
			"gm": main.gm,
			"is_ended": main.is_ended
		}
		
		Client.rpc_id(peer_id, "load_client", result)


func create_global_timer() -> void:
	if !is_server(): return
	
	update_timer = Timer.new()
	
	update_timer.wait_time = 0.5
	update_timer.one_shot = true
	
	main.add_child(update_timer)
	
	update_timer.start()
	
	update_timer.timeout.connect(global_update)


func create_weapon_pool() -> void:
	if !is_server(): return
	
	# Creating weapon pool via randi_range
	for count in range(main.amount_of_weapons):
		var random_pick = randi_range(1, Global.WEAPON_SCENES.size())
		
		main.weapon_pool.append(random_pick - 1)


func change_gamemode(gm) -> void:
	main.gm = gm
	
	match gm:
		"Standard":
			create_weapon_pool()
			main.weapon_craziness = 20.0
		"Competitive":
			create_weapon_pool()
			main.weapon_craziness = 0.0
		"Randomizer":
			main.weapon_craziness = 75.0


#region Rpcs
@rpc("any_peer", "call_local", "reliable")
func receive_new_player(data) -> void:
	add_player(data)


@rpc("call_remote", "any_peer", "reliable")
func shoot_animation(data) -> void:
	Client.rpc("receive_shoot_animation", data)


@rpc("call_remote", "any_peer", "reliable")
func reload_animation(data) -> void:
	Client.rpc("receive_reload_animation", data)


@rpc("call_remote", "any_peer", "reliable")
func push_corpse(data) -> void:
	var corpse = main.objects_folder.get_node(str(data["instance_name"]))
	
	if corpse != null:
		var push_dir = -data["normal"]
	
		var push_corpse_force = data["push_corpse_force"]
		
		corpse.apply_impulse(Vector3(0, 5, 0) + push_dir * push_corpse_force * 2)
		corpse.apply_torque_impulse(
			Vector3(
				randi_range(-2, 2),
				randi_range(-2, 2),
				randi_range(-2, 2)
			)
		)


@rpc("call_local", "any_peer", "reliable")
func receive_creation_of_test_object(data) -> void: # REWORK naming test object
	if !is_server(): return
	
	if data != {}:
		var testobject = main.testobject_scene.instantiate()
		var new_name = str(main.objects_folder.get_child_count() + 1)
		
		testobject.position = data["position"] + Vector3(0.0, 1.0, 0.0)
		
		testobject.name = "testObject" + new_name
		
		main.objects_folder.add_child(testobject, true)


@rpc("call_remote", "any_peer", "reliable")
func damage_test_enemy(data) -> void:
	var enemy = main.objects_folder.get_node(str(data["instance_name"]))
	
	if enemy != null:
		enemy.damage.rpc(data)


@rpc("call_remote", "any_peer", "reliable")
func damage_player(data) -> void:
	var peer_id = data["instance_name"]
	var player = main.players_folder.get_node(str(peer_id))
	
	if player != null:
		if peer_id == "1":
			player.damage.rpc(data)
		else:
			player.damage.rpc(data)


@rpc("call_remote", "any_peer", "reliable")
func global_update() -> void:
	if !is_server(): return
	
	update_timer.stop()
	update_timer.start()
	
	Client.receive_global_update.rpc()


@rpc("call_remote", "any_peer", "reliable")
func kill(data) -> void:
	# if server
	if !is_server(): return
	
	var killer_id = data["killer_id"]
	var killer = main.players_folder.get_node(str(killer_id))
	# if killer is dead
	if killer.is_player_dead: return
	
	var victim_id = data["victim_id"]
	# if player IS already dead
	if victim_id in dead_players: return
	
	# thehn
	var victim = main.players_folder.get_node(str(victim_id))
	
	# Creating corpse
	var corpse = corpse_scene.instantiate()
	
	corpse.global_transform = victim.global_transform
	main.objects_folder.add_child(corpse, true)
	
	var push_dir = -data["normal"]
	
	var push_corpse_force = data["push_corpse_force"]
	
	corpse.apply_impulse(Vector3(0, 5, 0) + push_dir * push_corpse_force * 6)
	corpse.apply_torque_impulse(
		Vector3(
			randi_range(-2, 2),
			randi_range(-2, 2),
			randi_range(-2, 2)
		)
	)
	
	Client.add_point.rpc(killer_id)
	
	Client.rpc("create_kill_log", int(killer_id), int(victim_id))
	
	if killer_id == 1:
		Client.create_eliminated_label(int(victim_id))
	else:
		Client.rpc_id(int(killer_id), "create_eliminated_label", int(victim_id))
	
	dead_players.append(victim_id)
	
	data["corpse_name"] = corpse.name
	
	# Sending signal to kill the player
	victim.die.rpc(data)


@rpc("call_remote", "any_peer", "reliable")
func respawn_player(victim_id, forceable : bool = false) -> void:
	if !is_server(): return
	
	var victim = main.players_folder.get_node(str(victim_id))
	
	# Choosing position to spawn
	var new_position : Vector3
	
	var spawn_area : Area3D = main.spawn_points_folder.get_children().pick_random()
	if spawn_area != null:
		var collision_shape = spawn_area.get_node("Collision")
		
		# Sizes
		var spawn_size_x = collision_shape.shape.size.x
		var spawn_size_z = collision_shape.shape.size.z
		
		# Setting new global position
		new_position = spawn_area.global_position
		new_position.x += randf_range(-spawn_size_x / 2, spawn_size_x / 2)
		new_position.z -= randf_range(-spawn_size_z / 2, spawn_size_z / 2)
	else:
		# Setting to default one
		new_position = Vector3(0, 2, 0)
	
	victim.respawn.rpc(new_position, forceable)


@rpc("call_remote", "any_peer", "reliable")
func kick_everyone() -> void:
	Client.leave.rpc()


@rpc("call_remote", "any_peer", "reliable")
func request_message(message, sender_id) -> void:
	Client.create_message.rpc(message, sender_id)


@rpc("call_remote", "any_peer", "reliable")
func restart_game() -> void:
	main.is_ended = false
	
	# Cleaning up the map
	for child in main.map_folder.get_children():
		main.map_folder.remove_child(child)
		child.queue_free()
	
	var new_map = load(Global.MAPS[randi_range(0, len(Global.MAPS) - 1)]).instantiate()
	new_map.name = "Map"
	main.map_folder.add_child(new_map)
	
	while new_map.get_node_or_null("SpawnPoints") == null:
		await get_tree().process_frame
	
	main.spawn_points_folder = new_map.get_node_or_null("SpawnPoints")
	
	# New gm
	var new_gm = Global.GAMEMODES[randi_range(0, len(Global.GAMEMODES) - 1)]
	#var new_gm = "Randomizer"
	main.weapon_pool = []
	
	for player in main.players_folder.get_children():
		var peer_id = int(player.name)
		main.scoreboard[peer_id] = 0
		
	main.gm = new_gm
	change_gamemode(new_gm)
	
	while main.weapon_pool == [] and new_gm != "Randomizer":
		await get_tree().process_frame
	
	var result : Dictionary = {
		"weapon_pool": main.weapon_pool,
		"player_list": main.player_list,
		"scoreboard": main.scoreboard,
		"amount_of_weapons": main.amount_of_weapons,
		"player_color_list": main.player_color_list,
		"player_accessories_face": main.player_accessories_face,
		"player_accessories_hat": main.player_accessories_hat,
		"player_quotes": main.player_quotes,
		"gm": main.gm,
		"is_ended": main.is_ended
	}
	
	# Reseting scoreboard and everything else
	for player in main.players_folder.get_children():
		var peer_id = int(player.name)
		result["peer_id"] = peer_id
		
		if new_gm != "Randomizer":
			if peer_id == 1:
				Client.load_client(result)
			else:
				Client.load_client.rpc_id(peer_id, result)
		
		respawn_player(peer_id, true)

#endregion

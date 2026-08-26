extends Node


@rpc("any_peer", "reliable") # Generating new stats for the player
func generate_new_weapon_stats(peer_id) -> void:
	var main = Server.main
	var weapon_craziness = main.weapon_craziness
	
	var player : Node = main.players_folder.get_node(str(peer_id))
	var guns : Node = player.guns_folder
	var gun : Node = guns.get_node("Gun")
	
	# Getting stats
	var weapon_stats = await gun.get_stats()
	
	var list_of_stats = [
		"damage", "fire_speed", "fire_type", "reload_speed", "player_speed_multiplier", "push_corpse_force", "recoil_strength", "max_ammo"
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
		elif stat == "burst":
			weapon_stats["damage"] /= 3.0
		
		weapon_stats[stat_string] = stat
	
	# Giving back new stats
	if peer_id != 1:
		Client.rpc_id(peer_id, "receive_new_weapon_stats", weapon_stats)
	else:
		Client.receive_new_weapon_stats(weapon_stats)

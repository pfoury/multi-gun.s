extends CharacterBody3D

const JUMP_VELOCITY := 4.5
const SPEED := 8.0
const MOVE_LERP_WEIGHT := 15.0
const GRAVITY := 15.0
const MAX_HEALTH : float = 150.0
const LOW_HEALTH_COLOR : Color = Color(676767)
const BUNNY_HOP_ACCELERATION : float = 0.7

@export var dust_walk_particles_scene : PackedScene = load("res://scenes/particles/dust_walk_particles.tscn")
@export var sound_scene : PackedScene = load("res://scenes/sounds/sound_effect.tscn")
@export var health_regeneration_particles_scene : PackedScene = load("res://scenes/particles/health_regeneration_particles.tscn")
@export var corpse_scene : PackedScene = load("res://scenes/corpse.tscn")
@export var player_fov : float = 80
# For MultiplayerSynchronizer
@export var velocity_length : float
@export var is_walk_timer_stopped : bool
@export var is_player_on_floor : bool
@export var player_color : Color = Color.DEEP_PINK
@export var player_health : float
@export var is_regen_timer_ready : bool = true
@export var is_player_dead : bool = false
@export var color_difference : float = 1.0

@onready var main_scene : Node = get_tree().current_scene
@onready var walk_timer : Timer = $WalkTimer
@onready var regen_timer : Timer = $RegenTimer
@onready var dead_timer : Timer = $DeadTimer
# Player's camera
@onready var camera_pivot : Node3D = $CameraPivot
@onready var first_person_camera : Camera3D = camera_pivot.find_child("FPCamera")
# Player's model
@onready var player_pivot := $Pivot
@onready var player_collision := $CollisionShape3D
@onready var player_capsule_mesh : MeshInstance3D = $Pivot/CapsuleMesh
# Folders
@onready var guns_folder : Node = $Guns
@onready var sounds_folder : Node = $Sounds

var player_speed : float = SPEED
var is_crouching : bool
var is_scoping : int = false
var is_in_menu : bool = false
var gun_node : Node
var gun_fire_type : String = ""
var scope_shadow_texture : TextureRect
var low_hp_shadow_texture : TextureRect
var white_screen_texture : ColorRect
var escape_menu_panel : PanelContainer
var unique_mat : Material
var killer_id : int
var look_at_killer_pivot : Node3D
var kill_cam_pivot : Camera3D
var weapon_speed_multiplier : float
var test_object_scene : PackedScene = load("res://scenes/temp/testobject.tscn")
var test_object : MeshInstance3D


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	player_health = MAX_HEALTH
	
	scope_shadow_texture = main_scene.player_hud.get_node("ScopeShadow")
	low_hp_shadow_texture = main_scene.player_hud.get_node("LowHPShadow")
	white_screen_texture = main_scene.player_hud.get_node("WhiteScreen")
	escape_menu_panel = main_scene.escape_menu
	
	unique_mat = player_capsule_mesh.get_active_material(0).duplicate()
	player_capsule_mesh.set_surface_override_material(0, unique_mat)
	
	request_to_respawn()


func _physics_process(delta: float) -> void:
	# Creating dust particles
	if velocity_length > 6 and is_walk_timer_stopped and is_player_on_floor:
		walk_timer.start()
		var dust_walk_particles = dust_walk_particles_scene.instantiate()
		
		dust_walk_particles.position = global_position - Vector3(0.0, 1.0, 0.0)
		
		main_scene.particles_folder.add_child(dust_walk_particles)
	
	# Health regenerating
	if player_health < MAX_HEALTH and is_regen_timer_ready:
		is_regen_timer_ready = false
		regen_timer.start()
	
	if not is_multiplayer_authority(): return
	
	# If players is dead, then do not calculate anything
	if is_player_dead: return
	
	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Jump
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Crouch
	is_crouching = Input.is_action_pressed("crouch")
	
	# Applying gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		if direction:
			velocity.x += direction.x * BUNNY_HOP_ACCELERATION * delta * 15.0
			velocity.z += direction.z * BUNNY_HOP_ACCELERATION * delta * 15.0
	else:
		if direction:
			velocity.x = lerp(velocity.x, direction.x * player_speed, delta * MOVE_LERP_WEIGHT)
			velocity.z = lerp(velocity.z, direction.z * player_speed, delta * MOVE_LERP_WEIGHT)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * MOVE_LERP_WEIGHT)
			velocity.z = lerp(velocity.z, 0.0, delta * MOVE_LERP_WEIGHT)


func _process(delta: float) -> void:
	# If players is dead, then do not calculate anything
	if is_player_dead:
		if dead_timer.time_left > 1.5:
			look_at_killer(delta)
		elif dead_timer.time_left == 0:
			request_to_respawn()
			is_player_dead = false
		else:
			look_at_killer_closely()
		return
	
	if not is_multiplayer_authority(): return
	
	if global_position.y < -100:
		request_to_respawn()
	
	global_rotation.y = first_person_camera.global_rotation.y
	guns_folder.rotation.y -= first_person_camera.rotation.y
	first_person_camera.rotation.y = 0
	
	# Input
	# Shooting
	# Checking if player does have a gun and player is not in menu
	if gun_node != null and gun_node.is_gun_ready() and !is_in_menu:
		# Fire type for each gun fire type (duh)
		if Input.is_action_pressed("shoot") and gun_fire_type == "auto":
			gun_node.fire()
		elif Input.is_action_just_pressed("shoot"):
			match gun_fire_type:
				"semi":
					gun_node.fire()
				"burst":
					for amount_of_fires in range(3):
						gun_node.fire()
						await get_tree().create_timer(0.05).timeout
				var unknown_fire_type:
					print("what the fuck is ", unknown_fire_type)
	
	# Scoping
	if Input.is_action_pressed("scope") and gun_node.is_scopable:
		is_scoping = 1
	else:
		is_scoping = 0
	
	# For multiplayerSynchronizer
	is_walk_timer_stopped = walk_timer.is_stopped()
	is_player_on_floor = is_on_floor()
	velocity_length = velocity.length()
	
	move_and_slide()
	update_player_height(delta)
	update_guns_transform(delta)
	update_player_fov(delta)
	update_player_hud(delta)
	
	is_in_menu = escape_menu_panel.is_in_menu


func _on_guns_child_entered_tree(node: Node) -> void: # Getting gun's data when created
	gun_node = node


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event.is_action_pressed("spawn"):
		# Setting up raycast from the player's camera
		var players_cam = first_person_camera.global_position
		var to = players_cam + -first_person_camera.global_transform.basis.z * 1000.0
		
		# Creating raycast
		var query = PhysicsRayQueryParameters3D.create(players_cam, to)
		query.exclude = [self]
		
		# Getting first intersect with raycast
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		Client.add_test_object(result)
	
	if event.is_action_pressed("reload") and gun_node != null and not gun_node.is_gun_reloading():
		gun_node.reload()


func play_kill_sound() -> void:
	var kill_sound = sound_scene.instantiate()
	
	kill_sound.folder_path = "res://common/sounds/kill_sound/"
	
	sounds_folder.add_child(kill_sound)


#region About updating player
func update_player_height(delta) -> void:
	# Maybe make like in source games: in the air, "move player up", otherwise "move player down".
	if is_crouching:
		player_pivot.scale.y = lerp(player_pivot.scale.y, 0.5, delta * 20)
		player_collision.shape.height = lerp(player_collision.shape.height, 1.0, delta * 20)
	else:
		player_pivot.scale.y = lerp(player_pivot.scale.y, 1.0, delta * 20)
		player_collision.shape.height = lerp(player_collision.shape.height, 2.0, delta * 20)
	update_player_camera(delta)
	player_speed = SPEED * player_pivot.scale.y * weapon_speed_multiplier \
	* (0.8 ** (is_scoping + 1)) # Making player slower because of crouching


func update_player_camera(delta) -> void:
	camera_pivot.position.y = lerp(camera_pivot.position.y, player_collision.shape.height / 4, delta * 20)


func update_player_fov(delta) -> void:
	var camera_fov = first_person_camera.fov
	
	var mouse_sensitivity = first_person_camera.mouse_sensitivity
	
	# Lerping fov, scope shadow and mouse sensitivity
	match is_scoping:
		1:
			camera_fov = lerp(camera_fov, 30.0, delta * 10)
			
			scope_shadow_texture.self_modulate.a = lerp(scope_shadow_texture.self_modulate.a, 0.45, delta * 10)
			scope_shadow_texture.offset_transform_scale = lerp(scope_shadow_texture.offset_transform_scale, Vector2(1.5, 1.5), delta * 10)
			
			mouse_sensitivity = lerp(mouse_sensitivity, Vector2(1.0, 1.0), delta * 10)
		0:
			camera_fov = lerp(camera_fov, player_fov, delta * 10)
			
			scope_shadow_texture.self_modulate.a = lerp(scope_shadow_texture.self_modulate.a, 0.0, delta * 10)
			scope_shadow_texture.offset_transform_scale = lerp(scope_shadow_texture.offset_transform_scale, Vector2(2, 2), delta * 10)
			
			mouse_sensitivity = lerp(mouse_sensitivity, Vector2(2.0, 2.0), delta * 10)
	
	first_person_camera.fov = camera_fov
	
	first_person_camera.update_mouse_sensitivity(mouse_sensitivity)


func update_guns_transform(delta) -> void:
	guns_folder.position = lerp(guns_folder.position, camera_pivot.position, delta * 5)
	guns_folder.rotation = lerp(guns_folder.rotation, first_person_camera.rotation + camera_pivot.rotation, delta * 25)
	
	guns_folder.position.y -= velocity.y * 0.0002


func update_gun_fire_type() -> void:
	gun_fire_type = gun_node.get_fire_type()


func update_weapon_speed_multiplier() -> void:
	weapon_speed_multiplier = gun_node.get_weapon_speed_multiplier()


func update_player_hud(delta) -> void:
	if not is_multiplayer_authority() or low_hp_shadow_texture == null: return
	
	white_screen_texture.self_modulate.a = lerp(white_screen_texture.self_modulate.a, 0.0, delta * 5)
	
	# Red glow
	match is_player_dead:
		false:
			low_hp_shadow_texture.self_modulate.a = lerp(low_hp_shadow_texture.self_modulate.a, 0.2 * color_difference, delta * 5)
			low_hp_shadow_texture.offset_transform_scale = lerp(low_hp_shadow_texture.offset_transform_scale, Vector2(2, 2) / (1 + color_difference), delta * 5)
		true:
			low_hp_shadow_texture.self_modulate.a = lerp(low_hp_shadow_texture.self_modulate.a, 0.0, delta * 5)
			low_hp_shadow_texture.offset_transform_scale = lerp(low_hp_shadow_texture.offset_transform_scale, Vector2(2, 2), delta * 5)
	
	# Escape menu
	match is_in_menu:
		false:
			escape_menu_panel.modulate.a = lerp(escape_menu_panel.modulate.a, 0.0, delta * 5)
			escape_menu_panel.offset_transform_position_ratio.x = lerp(escape_menu_panel.offset_transform_position_ratio.x, -1.0, delta * 10)
		true:
			escape_menu_panel.modulate.a = lerp(escape_menu_panel.modulate.a, 1.0, delta * 5)
			escape_menu_panel.offset_transform_position_ratio.x = lerp(escape_menu_panel.offset_transform_position_ratio.x, 0.0, delta * 10)
#endregion


#region About colors and shit
@rpc("reliable", "any_peer", "call_local")
func damage(data) -> void:
	if is_player_dead: return
	
	player_health -= data["damage"]
	regen_timer.start()
	
	if player_health <= 0 and is_multiplayer_authority():
		var result : Dictionary = {
			"killer_id": data["peer_id"],
			"victim_id": name,
			"normal": data["normal"],
			"push_force": data["push_force"]
		}
		if name == "1":
			Server.kill(result)
		else:
			Server.kill.rpc_id(1, result)
	else:
		change_color()


@rpc("reliable", "any_peer", "call_local")
func die(data) -> void:
	dead_timer.start()
	regen_timer.stop()
	
	var peer_id = data["killer_id"]
	
	if multiplayer.get_unique_id() == peer_id:
		var player = main_scene.players_folder.get_node(str(peer_id))
		
		player.play_kill_sound()
	elif is_multiplayer_authority():
		player_health = MAX_HEALTH
		
		killer_id = peer_id
		
		var killer : CharacterBody3D = main_scene.players_folder.get_node_or_null(str(killer_id))
		
		if killer == null: return
		
		# Calculating the distance between the player and the killer
		var distance := (first_person_camera.global_position - killer.global_position).length()
		
		# Creating look at node
		look_at_killer_pivot = Node3D.new()
		
		# Calculating pivot's pisition
		look_at_killer_pivot.position = first_person_camera.global_position
		look_at_killer_pivot.position.x -= sin(global_rotation.y) * distance
		look_at_killer_pivot.position.y += sin(first_person_camera.rotation.x) * distance
		look_at_killer_pivot.position.z -= cos(global_rotation.y) * distance
		
		look_at_killer_pivot.name = name + "'s look at killer"
		
		main_scene.objects_folder.add_child(look_at_killer_pivot)
		
		# Creating new camera
		kill_cam_pivot = Camera3D.new()
		
		kill_cam_pivot.position = first_person_camera.global_position
		kill_cam_pivot.name = name + "'s dead cam"
		kill_cam_pivot.fov = player_fov
		
		main_scene.objects_folder.add_child(kill_cam_pivot)
		
		first_person_camera.current = false
		kill_cam_pivot.current = true
		
		# Player is DEAD
		is_player_dead = true
		
		global_position = Vector3(0, -6767, 0)
	
	change_color()


func request_to_respawn() -> void:
	if name == "1":
		Server.respawn_player(1)
	elif is_multiplayer_authority():
		Server.respawn_player.rpc_id(1, int(name))


@rpc("reliable", "any_peer", "call_local")
func respawn(new_position) -> void:
	# Setting up for player's color
	player_health = MAX_HEALTH
	
	await get_tree().process_frame
	
	change_color()
	
	# Setting new position
	global_position = new_position
	
	# Creating spawn sound
	var sound = sound_scene.instantiate()
	
	sound.folder_path = "res://common/sounds/spawn/"
	
	sounds_folder.add_child(sound)
	
	if not is_multiplayer_authority(): return
	
	# --==--
	
	white_screen_texture.self_modulate.a = 1.0
	
	# Setting up camera and HUD
	if is_player_dead:
		kill_cam_pivot.current = false
		
		kill_cam_pivot.queue_free()
		look_at_killer_pivot.queue_free()
	
	first_person_camera.current = true
	
	first_person_camera.fov = player_fov


func look_at_killer(delta) -> void:
	if not is_multiplayer_authority(): return
	
	var killer = main_scene.players_folder.get_node_or_null(str(killer_id))
	
	if killer == null: return
	
	look_at_killer_pivot.position = look_at_killer_pivot.position.lerp(killer.first_person_camera.global_position, delta * 3)
	kill_cam_pivot.fov = lerp(kill_cam_pivot.fov, 35.0, delta * 5)
	
	kill_cam_pivot.look_at(look_at_killer_pivot.position, Vector3.UP)
	
	update_player_hud(delta)


func look_at_killer_closely() -> void:
	if not is_multiplayer_authority(): return
	
	var killer = main_scene.players_folder.get_node_or_null(str(killer_id))
	
	if killer == null: return
	
	var killers_camera = killer.first_person_camera
	
	kill_cam_pivot.global_transform = killers_camera.global_transform
	kill_cam_pivot.fov = player_fov
	
	# Calculating kill cam position
	kill_cam_pivot.global_position.x -= sin(killer.global_rotation.y) * 2
	kill_cam_pivot.global_position.y += sin(killers_camera.rotation.x) * 0.75
	kill_cam_pivot.global_position.z -= cos(killer.global_rotation.y) * 2
	
	kill_cam_pivot.look_at(killers_camera.global_position)


func change_color() -> void:
	if int(name) not in main_scene.player_color_list: return
	
	color_difference = 1.0 - (player_health / MAX_HEALTH)
	
	player_color = main_scene.player_color_list[int(name)]
	
	unique_mat.albedo_color = player_color.lerp(LOW_HEALTH_COLOR, color_difference)


func _on_regen_timer_timeout() -> void:
	is_regen_timer_ready = true
	
	player_health += MAX_HEALTH / 10.0
	if player_health > MAX_HEALTH: player_health = MAX_HEALTH
	
	change_color()
	
	# Creating health regeneration particles
	if randi_range(1, 2) == 2: # Creating with 50% chance
		var health_regeneration_particles = health_regeneration_particles_scene.instantiate()
		
		health_regeneration_particles.position = global_position
		
		main_scene.particles_folder.add_child(health_regeneration_particles)
#endregion

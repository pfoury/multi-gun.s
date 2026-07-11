extends CharacterBody3D

const JUMP_VELOCITY := 4.5
const SPEED := 8.0
const MOVE_LERP_WEIGHT := 15.0
const GRAVITY := 15.0

@export var dust_walk_particles_scene : PackedScene = load("res://scenes/particles/dust_walk_particles.tscn")
@export var kill_sound_scene : PackedScene = load("res://scenes/sounds/kill_sound_effect.tscn")
# For MultiplayerSynchronizer
@export var velocity_length : float
@export var is_walk_timer_stopped : bool
@export var is_player_on_floor : bool

@onready var main_scene := get_tree().current_scene
@onready var walk_timer := $WalkTimer
# Player's camera
@onready var camera_pivot := $CameraPivot
@onready var first_person_camera := camera_pivot.find_child("FPCamera")
# Player's model
@onready var player_mesh := $Pivot
@onready var player_collision := $CollisionShape3D
# Folders
@onready var guns_folder : Node = $Guns
@onready var sounds_folder : Node = $Sounds

var player_speed : float = SPEED
var is_crouching : bool
var gun_node : Node
var gun_fire_type : String = ""

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	if not is_multiplayer_authority(): return
	
	first_person_camera.current = true


func _physics_process(delta: float) -> void:
	if velocity_length > 6 and is_walk_timer_stopped and is_player_on_floor:
		walk_timer.start()
		var dust_walk_particles = dust_walk_particles_scene.instantiate()
		
		dust_walk_particles.position = global_position - Vector3(0.0, 1.0, 0.0)
		
		main_scene.particles_folder.add_child(dust_walk_particles)
	
	if not is_multiplayer_authority(): return
	
	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Crouch
	is_crouching = Input.is_action_pressed("crouch")
	
	# Applying gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		if direction:
			velocity.x = lerp(velocity.x, direction.x * player_speed, delta * MOVE_LERP_WEIGHT)
			velocity.z = lerp(velocity.z, direction.z * player_speed, delta * MOVE_LERP_WEIGHT)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * MOVE_LERP_WEIGHT)
			velocity.z = lerp(velocity.z, 0.0, delta * MOVE_LERP_WEIGHT)


func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	global_rotation.y = first_person_camera.global_rotation.y
	guns_folder.rotation.y -= first_person_camera.rotation.y
	first_person_camera.rotation.y = 0
	
	# For MultiplayerSynchronizer
	velocity_length = velocity.length()
	is_walk_timer_stopped = walk_timer.is_stopped()
	is_player_on_floor = is_on_floor()
	
	# Input
	# Shoot
	# Checking if player does have a gun
	if gun_node != null and gun_node.is_gun_ready():
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
	
	move_and_slide()
	update_player_height(delta)
	update_guns_transform(delta)


func _on_guns_child_entered_tree(node: Node) -> void: # Getting gun's data when created
	gun_node = node
	gun_fire_type = gun_node.get_fire_type()[0]


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
		
		main_scene.add_test_object(result)
	
	if event.is_action_pressed("reload") and gun_node != null and not gun_node.is_gun_reloading():
		gun_node.reload()


func play_kill_sound() -> void:
	var kill_sound = kill_sound_scene.instantiate()
	
	sounds_folder.add_child(kill_sound)


func update_player_height(delta) -> void:
	# Maybe make like in source games: in the air, "move player up", otherwise "move player down".
	if is_crouching:
		player_mesh.scale.y = lerp(player_mesh.scale.y, 0.5, delta * 20)
		player_collision.shape.height = lerp(player_collision.shape.height, 1.0, delta * 20)
	else:
		player_mesh.scale.y = lerp(player_mesh.scale.y, 1.0, delta * 20)
		player_collision.shape.height = lerp(player_collision.shape.height, 2.0, delta * 20)
	update_player_camera(delta)
	player_speed = SPEED * player_mesh.scale.y # Making player slower because of crouching


func update_player_camera(delta) -> void:
	camera_pivot.position.y = lerp(camera_pivot.position.y, player_collision.shape.height / 4, delta * 20)


func update_guns_transform(delta) -> void:
	guns_folder.position = lerp(guns_folder.position, camera_pivot.position, delta * 5)
	guns_folder.rotation = lerp(guns_folder.rotation, first_person_camera.rotation, delta * 25)

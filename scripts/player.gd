extends CharacterBody3D

const JUMP_VELOCITY := 4.5
const SPEED := 8.0
const MOVE_LERP_WEIGHT := 15.0
const GRAVITY := 15.0

@export var testobject_scene : PackedScene

@onready var main_scene := get_tree().current_scene
# Player's camera
@onready var camera_pivot := $CameraPivot
@onready var first_person_camera := camera_pivot.find_child("FPCamera")
# Player's model
@onready var player_mesh := $Pivot
@onready var player_collision := $CollisionShape3D
# Weapons' folder
@onready var guns_folder := $Guns

var player_speed: float = SPEED
var is_crouching: bool


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	if not is_multiplayer_authority(): return
	
	first_person_camera.current = true


func _physics_process(delta: float) -> void:
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
	
	move_and_slide()
	update_player_height(delta)
	update_guns_transform(delta)


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

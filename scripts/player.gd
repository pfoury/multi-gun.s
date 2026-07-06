extends CharacterBody3D

const JUMP_VELOCITY := 4.5
const SPEED := 8.0
const MOVE_LERP_WEIGHT := 15.0

@export var testobject_scene : PackedScene

@onready var first_person_camera := $CameraPivot/FPCamera
@onready var main_scene := get_tree().current_scene

var player_speed: float = SPEED


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Applying gravity
	if not is_on_floor():
		velocity.y -= 15.0 * delta
	else:
		if direction:
			velocity.x = lerp(velocity.x, direction.x * player_speed, delta * MOVE_LERP_WEIGHT)
			velocity.z = lerp(velocity.z, direction.z * player_speed, delta * MOVE_LERP_WEIGHT)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * MOVE_LERP_WEIGHT)
			velocity.z = lerp(velocity.z, 0.0, delta * MOVE_LERP_WEIGHT)


func _process(delta: float) -> void:
	global_rotation.y = first_person_camera.global_rotation.y
	first_person_camera.rotation.y = 0
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn"):
		# Setting up raycast from the player's camera
		var players_cam = first_person_camera.global_position
		var to = players_cam + -first_person_camera.global_transform.basis.z * 1000.0
		
		# Creating raycast
		var query = PhysicsRayQueryParameters3D.create(players_cam, to)
		query.exclude = [self]
		
		# Getting first intersect with raycast
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		
		var testobject = testobject_scene.instantiate()
		
		if result != {}:
			testobject.position = result["position"]
			
			var normal = result["normal"]
		
			var tangent = normal.cross(Vector3.UP)
			if tangent.length_squared() < 0.0001:
				tangent = normal.cross(Vector3.RIGHT)

			tangent = tangent.normalized()
			
			testobject.look_at_from_position(testobject.position, testobject.position - result["normal"], tangent)
			
			main_scene.add_child(testobject)

extends CharacterBody3D

const JUMP_VELOCITY = 4.5
const SPEED := 8.0
const MOVE_LERP_WEIGHT := 15.0

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
	move_and_slide()

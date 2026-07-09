extends Camera3D

@export var mouse_sensitivity : Vector2 = Vector2(2.0, 2.0)

@onready var camera_pivot = $".."
@onready var player = $"../.."

var rotation_velocity: Vector2 = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_multiplayer_authority(str(player.name).to_int())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if !rotation_velocity.is_zero_approx():
		var rotation_amount = rotation_velocity * minf(delta * 100, 1)

		rotation.y = rotation.y - rotation_amount.x
		rotation.x = clamp(rotation.x - rotation_amount.y, -PI/2, PI/2)

		rotation_velocity -= rotation_amount
	
	update_camera_pivot(delta)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_velocity += event.screen_relative / (Vector2)(get_viewport().size / 2) * mouse_sensitivity


func update_camera_pivot(delta) -> void: # I'm doing it here because I don't want to have a lot of fucking scripts in this project.
	camera_pivot.rotation.x = lerp(camera_pivot.rotation.x, 0.0, delta * 5)

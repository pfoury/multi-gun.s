extends Camera3D

@export var mouse_sensitivity : Vector2 = Vector2(2.0, 2.0)
@export var recoil_recovery_speed : float = 5.0

@onready var camera_pivot = $".."
@onready var player = $"../.."

var rotation_velocity: Vector2 = Vector2()
var is_in_menu : bool = false
var recoil_offset : float = 0.0
var camera_rotation : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_multiplayer_authority(str(player.name).to_int())
	
	if not is_multiplayer_authority() or player.is_player_dead: return
	
	camera_rotation = rotation.x
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	recoil_offset = lerp(recoil_offset, 0.0, delta * recoil_recovery_speed)
	
	camera_pivot.transform.basis = Basis(Vector3.RIGHT, recoil_offset)


func _process(delta: float) -> void:
	if not is_multiplayer_authority() or player.is_player_dead: return
	
	if !rotation_velocity.is_zero_approx():
		var rotation_amount = rotation_velocity * minf(delta * 100, 1)

		rotation.y = rotation.y - rotation_amount.x
		rotation.x = clamp(rotation.x - rotation_amount.y, -PI/2, PI/2)

		rotation_velocity -= rotation_amount
	
	is_in_menu = player.is_in_menu
	match is_in_menu:
		true:
			@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
			Input.set_mouse_mode(0)
		false:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_velocity += event.screen_relative / (Vector2)(get_viewport().size / 2) * mouse_sensitivity


func apply_recoil(recoil_strength) -> void:
	recoil_offset += deg_to_rad(recoil_strength)


func update_mouse_sensitivity(new_mouse_sensitivity) -> void:
	mouse_sensitivity = new_mouse_sensitivity

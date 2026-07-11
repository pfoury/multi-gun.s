extends RigidBody3D


func _ready() -> void:
	await get_tree().create_timer(2.5).timeout
	queue_free()

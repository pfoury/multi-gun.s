@icon("res://common/icons/ParticlesIcon.svg")

class_name SmallParticles extends Node3D

# This script is made for small particles,
# such as dust walk, dust hit, etc.
# For other particles please use other scripts.

func _ready() -> void:
	var particles = get_children()
	
	for particle in particles:
		particle.visible = true
		particle.one_shot = true
		particle.emitting = true
	
	await get_tree().create_timer(1).timeout
	
	queue_free()

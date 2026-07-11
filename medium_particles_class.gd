@icon("res://common/icons/MediumParticlesIcon.svg")

class_name MediumParticles extends Node3D

# This script is made for medium particles,
# such as health regeneration, spawn shield, etc.
# For other particles please use other classes.

func _ready() -> void:
	var particles = get_children()
	
	for particle in particles:
		particle.visible = true
		particle.one_shot = true
		particle.emitting = true
	
	await get_tree().create_timer(5).timeout
	
	queue_free()

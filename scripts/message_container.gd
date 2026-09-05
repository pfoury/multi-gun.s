extends MarginContainer

@export var username : String = "OnlyTwentyCharacters"
@export var message_text : String = "Hello world!"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var username_label: Label = $HBC/UsernameLabel
@onready var message_label: Label = $HBC/MessageLabel


func _ready() -> void:
	username_label.text = username
	message_label.text = message_text
	
	animation_player.play("start")
	
	await animation_player.animation_finished
	
	queue_free()

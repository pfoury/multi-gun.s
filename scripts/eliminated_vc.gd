extends HBoxContainer

@export var victim_username : String = "OnlyTwentyCharacters"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var victim_username_label: RichTextLabel = $VictimUsernameLabel


func _ready() -> void:
	victim_username_label.text = "[wave amp=10 freq=3 speed=1 ease=-10.0]" + victim_username + "[/wave]"
	
	animation_player.play("start")
	
	await animation_player.animation_finished
	
	queue_free()

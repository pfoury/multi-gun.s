extends Node

# HUD
@onready var menu: PanelContainer = $MainMenu/Menu
@onready var close_button: PanelContainer = $MainMenu/CloseButton
@onready var customization: PanelContainer = $MainMenu/Customization
@onready var player_customization: PanelContainer = $MainMenu/PlayerCustomization
@onready var settings: MarginContainer = $MainMenu/Settings
@onready var about: MarginContainer = $MainMenu/About
@onready var deploy: MarginContainer = $MainMenu/Deploy

# hashtag haha funny

# Animations
@onready var camera_player: AnimationPlayer = $CameraPlayer
@onready var menu_player: AnimationPlayer = $MenuPlayer

# Player Customization
@onready var player_platform: Node3D = $Platforms/Player
@onready var player_mesh : MeshInstance3D = $Platforms/Player/Player
@onready var accessory_pivot: Node3D = $Platforms/Player/Player/AccessoryPivot


var args : Dictionary = {
	"username": "Newbie",
	"quote": "I didn't change my quote bleh",
	"color": Color("FF34FF"),
	"hat": 0,
	"face": 0,
	"gm": "Standard",
	"map": "dm_matrix",
	"peer": "client",
	"scoregoal": 32,
}
var is_deploy : bool = false
var is_customize : bool = false

func _ready() -> void:
	Global.is_in_game = false
	
	if multiplayer.has_multiplayer_peer(): multiplayer.multiplayer_peer.close()
	
	camera_player.play("intro")
	menu_player.play("intro")
	
	load_customization()
	settings.get_node("Settings")._load_settings()


func _process(delta: float) -> void:
	player_platform.rotation.y += 0.5 * delta


func _on_close_button_pressed() -> void:
	if is_deploy:
		camera_player.play("deploy_end")
		is_deploy = false
	elif is_customize:
		camera_player.play("customization_end")
		customization.hide()
		player_customization.hide()
		is_customize = false
	
	menu.show()
	settings.hide()
	about.hide()
	deploy.hide()
	close_button.hide()


func load_customization() -> void:
	var player_settings = ConfigFileHandler.load_player_setting()
	var accessories_settings = ConfigFileHandler.load_accessories_setting()
	
	args["username"] = player_settings.username
	args["quote"] = player_settings.quote
	args["color"] = player_settings.color
	
	args["hat"] = accessories_settings.hat
	args["face"] = accessories_settings.face
	
	customization._load_customization_settings()
	player_customization._load_player_customization_settings()


func change_scene() -> void:
	_creating_args()
	
	Global.change_scene_with_arguments("res://scenes/main_game.tscn", args)


func _creating_args() -> void:
	var pl_cus : Dictionary = player_customization.args
	var acc_cus : Dictionary = customization.args
	
	# Player Customization
	for string in ["username", "quote"]:
		args[string] = pl_cus[string]
	
	# Accessory Customization
	for string in ["color", "hat", "face"]:
		args[string] = acc_cus[string]

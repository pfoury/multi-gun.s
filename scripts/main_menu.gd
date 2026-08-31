extends Node

# HUD
@onready var menu: PanelContainer = $MainMenu/Menu
@onready var close_button: PanelContainer = $MainMenu/CloseButton
@onready var customization: PanelContainer = $MainMenu/Customization
@onready var player_customization: PanelContainer = $MainMenu/PlayerCustomization

@onready var host: Button = $MainMenuOLD/MainTab/VBoxContainer/HBoxContainer/Host
@onready var host_debug: Button = $MainMenuOLD/MainTab/VBoxContainer/HBoxContainer/HostDebug
@onready var join: Button = $MainMenuOLD/MainTab/VBoxContainer/HBoxContainer2/Join
@onready var join_debug: Button = $MainMenuOLD/MainTab/VBoxContainer/HBoxContainer2/JoinDebug
@onready var ip_grabber: LineEdit = $MainMenuOLD/MainTab/VBoxContainer/IPGrabber

# hashtag haha funny

# Animations
@onready var camera_player: AnimationPlayer = $CameraPlayer
@onready var menu_player: AnimationPlayer = $MenuPlayer

# Player Customization
@onready var player_platform: Node3D = $Platforms/Player
@onready var display_nickname: LineEdit = $MainMenuOLD/PlayerCustomization/VBoxContainer/DisplayNickname
@onready var hex_color: LineEdit = $MainMenuOLD/PlayerCustomization/VBoxContainer/HEXColor
@onready var player_mesh : MeshInstance3D = $Platforms/Player/Player
@onready var accessory_pivot: Node3D = $Platforms/Player/Player/AccessoryPivot

# Test
@onready var gm_line_edit: LineEdit = $MainMenuOLD/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var map_line_edit: LineEdit = $MainMenuOLD/HBoxContainer/VBoxContainer/HBoxContainer2/LineEdit

var args : Dictionary = {
	"username": "Newbie",
	"quote": "I didn't change my quote bleh",
	"color": Color("FF34FF"),
	"hat": 0,
	"face": 0,
	"gm": "Standard",
	"map": "Matrix",
	"peer": "client",
}
var is_deploy : bool = false
var is_customize : bool = false

func _ready() -> void:
	Global.is_in_game = false
	
	camera_player.play("intro")
	menu_player.play("intro")
	
	load_customization()


func _process(delta: float) -> void:
	player_platform.rotation.y += 0.2 * delta


func _on_deploy_button_pressed() -> void:
	is_deploy = true
	menu.hide()
	close_button.show()
	camera_player.play("deploy_start")

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


func creating_args() -> void:
	# Gamemode
	match gm_line_edit.text.to_lower():
		"s":
			args["gm"] = "Standard"
		"r":
			args["gm"] = "Randomizer"
		"c":
			args["gm"] = "Competitive"
		_:
			args["gm"] = "Standard"
	
	# Map
	match map_line_edit.text.to_lower()[0]:
		"g":
			args["map"] = "Grey"
		"m":
			args["map"] = "Matrix"
		_:
			args["map"] = "Matrix"

#region For debuggin
func _on_host_debug_pressed() -> void: # For debuggin
	# Setting up host
	args["peer"] = "host"
	creating_args()
	
	Global.change_scene_with_arguments("res://scenes/main_game.tscn", args)


func _on_join_debug_pressed() -> void: # For debuggin
	# Setting up client
	args["peer"] = "client"
	creating_args()
	
	Global.change_scene_with_arguments("res://scenes/main_game.tscn", args)
#endregion


#region For multiplayer
func _on_host_pressed() -> void:
	# Setting up host
	args["peer"] = "host"
	creating_args()
	
	Global.change_scene_with_arguments("res://scenes/main_game.tscn", args)


func _on_join_pressed() -> void:
	# Setting up client
	args["peer"] = "client"
	args["ip"] = ip_grabber.text
	creating_args()
	
	Global.change_scene_with_arguments("res://scenes/main_game.tscn", args)
#endregion


#region Customization

#endregion

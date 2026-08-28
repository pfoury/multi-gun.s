extends Node

# Main tab
@onready var host: Button = $MainMenuOLD/MainTab/VBoxContainer/HBoxContainer/Host
@onready var host_debug: Button = $MainMenuOLD/MainTab/VBoxContainer/HBoxContainer/HostDebug
@onready var join: Button = $MainMenuOLD/MainTab/VBoxContainer/HBoxContainer2/Join
@onready var join_debug: Button = $MainMenuOLD/MainTab/VBoxContainer/HBoxContainer2/JoinDebug
@onready var ip_grabber: LineEdit = $MainMenuOLD/MainTab/VBoxContainer/IPGrabber

# Animations
@onready var camera_player: AnimationPlayer = $CameraPlayer
@onready var menu_player: AnimationPlayer = $MenuPlayer

# Player Customization
@onready var display_nickname: LineEdit = $MainMenuOLD/PlayerCustomization/VBoxContainer/DisplayNickname
@onready var hex_color: LineEdit = $MainMenuOLD/PlayerCustomization/VBoxContainer/HEXColor

# Test
@onready var gm_line_edit: LineEdit = $MainMenuOLD/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var map_line_edit: LineEdit = $MainMenuOLD/HBoxContainer/VBoxContainer/HBoxContainer2/LineEdit

var args : Dictionary = {}


func _ready() -> void:
	Global.is_in_game = false
	
	camera_player.play("intro")
	menu_player.play("intro")


func creating_args() -> void:
	# Setting username
	if len(display_nickname.text) < 3 or len(display_nickname.text) > 20:
		args["username"] = "OnlyTwentyCharacters"
	else:
		args["username"] = display_nickname.text
	
	# Setting color
	if "#" not in hex_color.text or len(hex_color.text) != 7:
		var random_color = Color(randf(), randf(), randf())
		
		args["color"] = random_color
	else:
		args["color"] = Color(hex_color.text)
	
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

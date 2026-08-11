extends PanelContainer

# Buttons
@onready var camera_button: Button = $PC/VBC/ButtonsContainer/CameraButton
@onready var display_button: Button = $PC/VBC/ButtonsContainer/DisplayButton
@onready var video_button: Button = $PC/VBC/ButtonsContainer/VideoButton
@onready var audio_button: Button = $PC/VBC/ButtonsContainer/AudioButton

# Options
@onready var camera_options: VBoxContainer = $PC/VBC/CameraOptions
@onready var display_options: VBoxContainer = $PC/VBC/DisplayOptions
@onready var video_options: VBoxContainer = $PC/VBC/VideoOptions
@onready var audio_options: VBoxContainer = $PC/VBC/AudioOptions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setting up everything
	setting_up()


func setting_up(node_name : String = "camera") -> void:
	# Setting everything to off
	camera_options.hide()
	display_options.hide()
	video_options.hide()
	audio_options.hide()
	
	camera_button.disabled = false
	display_button.disabled = false
	video_button.disabled = false
	audio_button.disabled = false
	
	# ..then turning on what 
	get(node_name + "_options").show()
	get(node_name + "_button").disabled = true


#region Buttons' logic
func _on_camera_button_pressed() -> void:
	setting_up("camera")


func _on_display_button_pressed() -> void:
	setting_up("display")


func _on_video_button_pressed() -> void:
	setting_up("video")


func _on_audio_button_pressed() -> void:
	setting_up("audio")

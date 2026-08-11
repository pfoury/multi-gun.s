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

# Sensitivity
@onready var sens_h_slider: HSlider = $PC/VBC/CameraOptions/Sensitivity/HSlider
@onready var sens_line_edit: LineEdit = $PC/VBC/CameraOptions/Sensitivity/LineEdit

# FOV
@onready var fov_line_edit: LineEdit = $PC/VBC/CameraOptions/FOV/LineEdit

# Resolution
@onready var resolutions: OptionButton = $PC/VBC/DisplayOptions/Resolution/Resolutions

# FPS
@onready var fps_line_edit: LineEdit = $PC/VBC/DisplayOptions/FPS/LineEdit

# Window types
@onready var window_types: OptionButton = $PC/VBC/DisplayOptions/WindowType/WindowTypes


var master_idx = AudioServer.get_bus_index("Master")
var respawn_sounds_idx = AudioServer.get_bus_index("RespawnSounds")
var gun_sfx_idx = AudioServer.get_bus_index("GunSFX")
var kill_effects_idx = AudioServer.get_bus_index("KillEffectsSound")
var death_idx = AudioServer.get_bus_index("DeathSound")


func _ready() -> void:
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
	
	# ..then turning on what you need
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
#endregion


#region Camera options
# Sensitivity
func _sensitivity_slider_changed(value: float) -> void:
	sens_line_edit.text = str(round(value * 100) / 100)


func _sensitivity_line_submitted(new_text: String) -> void:
	var new_value = float(new_text)
	
	if new_value < 0.0:
		new_value = 0.0
	elif new_value > 10.0:
		new_value = 10.0
	sens_line_edit.text = str(new_value)
	
	sens_h_slider.value = new_value
	
	Global.sensitivity = Vector2(new_value, new_value)


# FOV
func _fov_changed(new_text: String) -> void:
	var new_value = int(new_text)
	
	if new_value < 20:
		new_value = 20
	elif new_value > 200:
		new_value = 200
	fov_line_edit.text = str(new_value)
	
	Global.fov = new_value
#endregion


#region Display options
# Resolution
func _resolutions_item_selected(index: int) -> void:
	var new_resolution = resolutions.get_item_text(index).split("×")
	
	var new_size = Vector2i(int(new_resolution[0]), int(new_resolution[1]))
	
	DisplayServer.window_set_size(new_size)


# FPS
func _new_fps_submitted(new_text: String) -> void:
	var new_value = int(new_text)
	
	if new_value < 0:
		new_value = 0
		fps_line_edit.text = "0"
	
	Engine.max_fps = new_value


# VSync
func _vsync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


# Window Type
func _window_types_selected(index: int) -> void:
	var new_window_type = window_types.get_item_text(index)
	
	if new_window_type == "Fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		resolutions.disabled = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		resolutions.disabled = false


# Borderless
func _borderless_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, toggled_on)


# Barbie Mode
func _barbie_mode_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
#endregion


#region Audio options
# Master
func _master_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_idx, linear_to_db(value))


# Respawn
func _respawn_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(respawn_sounds_idx, linear_to_db(value))


# Guns
func _guns_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(gun_sfx_idx, linear_to_db(value))


# Kill Effects
func _kill_effect_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(kill_effects_idx, linear_to_db(value))


# Death
func _death_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(death_idx, linear_to_db(value))
#endregion


#region Video options

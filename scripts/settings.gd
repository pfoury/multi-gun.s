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

# Brightness
@onready var b_h_slider: HSlider = $PC/VBC/VideoOptions/Brightness/HSlider
@onready var b_line_edit: LineEdit = $PC/VBC/VideoOptions/Brightness/LineEdit

# Sky Brightness
@onready var sb_h_slider: HSlider = $PC/VBC/VideoOptions/SkyBrightness/HSlider
@onready var sb_line_edit: LineEdit = $PC/VBC/VideoOptions/SkyBrightness/LineEdit

# Glow
@onready var glow_h_slider: HSlider = $PC/VBC/VideoOptions/Glow/HSlider
@onready var glow_line_edit: LineEdit = $PC/VBC/VideoOptions/Glow/LineEdit

# Soft Shadow
@onready var ss_option_button: OptionButton = $PC/VBC/VideoOptions/SoftShadow/OptionButton

# SSAO
@onready var ssao_option_button: OptionButton = $PC/VBC/VideoOptions/SSAO/OptionButton

# SSIL
@onready var ssil_option_button: OptionButton = $PC/VBC/VideoOptions/SSIL/OptionButton

# MSAA
@onready var msaa_option_button: OptionButton = $PC/VBC/VideoOptions/MSAA/OptionButton

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
	sens_line_edit.text = str(value)
	sens_line_edit.placeholder_text = str(value)
	
	Global.sensitivity = Vector2(value, value)

func _sensitivity_line_submitted(new_text: String) -> void:
	var new_value = float(new_text)
	
	if ! (new_text.is_valid_float() or new_text.is_valid_int()):
		sens_line_edit.text = sens_line_edit.placeholder_text
		return
	
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
	
	if ! (new_text.is_valid_float() or new_text.is_valid_int()):
		fov_line_edit.text = fov_line_edit.placeholder_text
		return
	
	if new_value < 20:
		new_value = 20
	elif new_value > 200:
		new_value = 200
	fov_line_edit.text = str(new_value)
	fov_line_edit.placeholder_text = str(new_value)
	
	Global.fov = new_value
	
	if Global.is_in_game:
		Global._update_fov()
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
	
	if ! (new_text.is_valid_float() or new_text.is_valid_int()):
		fps_line_edit.text = fps_line_edit.placeholder_text
		return
	
	if new_value < 0:
		new_value = 0
	fps_line_edit.text = str(new_value)
	fps_line_edit.placeholder_text = str(new_value)
	
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
# Brightness
func _brightness_changed(value: float) -> void:
	b_line_edit.text = str(value)
	b_line_edit.placeholder_text = str(value)
	
	Global.brightness = value
	
	if Global.is_in_game:
		Global._update_brightness()

func _brightness_submitted(new_text: String) -> void:
	var new_value = float(new_text)
	
	if ! (new_text.is_valid_float() or new_text.is_valid_int()):
		b_line_edit.text = b_line_edit.placeholder_text
		return
	
	if new_value < 0.0:
		new_value = 0.0
	elif new_value > 10.0:
		new_value = 10.0
	b_line_edit.text = str(new_value)
	b_line_edit.placeholder_text = str(new_value)
	
	b_h_slider.value = new_value
	
	Global.brightness = new_value
	
	if Global.is_in_game:
		Global._update_brightness()


# Sky Brightness
func _sky_brightness_changed(value: float) -> void:
	sb_line_edit.text = str(value)
	sb_line_edit.placeholder_text = str(value)
	
	Global.sky_brightness = value
	
	if Global.is_in_game:
		Global._update_sky_brightness()

func _sky_brightness_submitted(new_text: String) -> void:
	var new_value = float(new_text)
	
	if ! (new_text.is_valid_float() or new_text.is_valid_int()):
		sb_line_edit.text = sb_line_edit.placeholder_text
		return
	
	if new_value < 0.0:
		new_value = 0.0
	elif new_value > 10.0:
		new_value = 10.0
	sb_line_edit.text = str(new_value)
	sb_line_edit.placeholder_text = str(new_value)
	
	sb_h_slider.value = new_value
	
	Global.sky_brightness = new_value
	
	if Global.is_in_game:
		Global._update_sky_brightness()


# Glow
func _glow_toggled(toggled_on: bool) -> void:
	glow_h_slider.editable = toggled_on
	
	glow_line_edit.editable = toggled_on
	
	Global.is_glow = toggled_on
	
	if Global.is_in_game:
		Global._update_glow()

func _glow_changed(value: float) -> void:
	glow_line_edit.text = str(value)
	glow_line_edit.placeholder_text = str(value)
	
	Global.glow = value
	
	if Global.is_in_game:
		Global._update_glow()

func _glow_submitted(new_text: String) -> void:
	var new_value = float(new_text)
	
	if ! (new_text.is_valid_float() or new_text.is_valid_int()):
		glow_line_edit.text = glow_line_edit.placeholder_text
		return
	
	if new_value < 0.0:
		new_value = 0.0
	elif new_value > 2.0:
		new_value = 2.0
	glow_line_edit.text = str(new_value)
	glow_line_edit.placeholder_text = str(new_value)
	
	glow_h_slider.value = new_value
	
	Global.glow = new_value
	
	if Global.is_in_game:
		Global._update_glow()


# Occlusion Culling
func _occlusion_culling_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting("rendering/occlusion_culling/use_occlusion_culling", toggled_on)


# Anisotropic
func _anisotropic_selected(index: int) -> void:
	ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", index)


# Soft shadow
func _soft_shadow_selected(index: int) -> void:
	var new_shadow = ss_option_button.get_item_text(index)
	
	if "Fastest" in new_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
	elif "Faster" in new_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
	elif "Fast" in new_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	elif "Average" in new_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	elif "Slow" in new_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	else:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)


# SSAO
func _ssao_toggled(toggled_on: bool) -> void:
	ssao_option_button.disabled = !toggled_on
	
	Global.is_ssao = toggled_on
	
	if Global.is_in_game:
		Global._update_SSAO()

func _ssao_selected(index: int) -> void:
	var new_ssao = ssao_option_button.get_item_text(index)
	
	Global.ssao = new_ssao
	
	if Global.is_in_game:
		Global._update_SSAO()


# SSIL
func _ssil_toggled(toggled_on: bool) -> void:
	ssil_option_button.disabled = !toggled_on
	
	Global.is_ssil = toggled_on
	
	if Global.is_in_game:
		Global._update_SSIL()

func _ssil_selected(index: int) -> void:
	var new_ssil = ssil_option_button.get_item_text(index)
	
	Global.ssil = new_ssil
	
	if Global.is_in_game:
		Global._update_SSIL()


# MSAA
func _msaa_selected(index: int) -> void:
	var new_msaa = msaa_option_button.get_item_text(index)
	
	if "Fastest" in new_msaa:
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif "Average" in new_msaa:
		get_viewport().msaa_3d = Viewport.MSAA_2X
	elif "Slow" in new_msaa:
		get_viewport().msaa_3d = Viewport.MSAA_4X
	else:
		get_viewport().msaa_3d = Viewport.MSAA_8X


# TAA (like that emoji from twitch xdd)
func _taa_toggled(toggled_on: bool) -> void:
	get_viewport().use_taa = toggled_on


# SSR
func _ssr_toggled(toggled_on: bool) -> void:
	Global.is_ssr = toggled_on
	
	if Global.is_in_game:
		Global._update_SSR()


# SDFGI
func _sdfgi_toggled(toggled_on: bool) -> void:
	Global.is_sdfgi = toggled_on
	
	if Global.is_in_game:
		Global._update_SDFGI()

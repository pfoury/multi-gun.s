extends Node

var config_settings = ConfigFile.new()
var config_player = ConfigFile.new()


func load_configs() -> void:
	# Settings
	if !FileAccess.file_exists(Global.SETTINGS_FILE_PATH):
		# Camera
		config_settings.set_value("camera", "sensitivity", 2.0)
		config_settings.set_value("camera", "fov", 80)
		config_settings.set_value("camera", "fov_multiplier", 1.0)
		
		# Display
		config_settings.set_value("display", "resolution", 7)
		config_settings.set_value("display", "fps", 0)
		config_settings.set_value("display", "vsync", false)
		config_settings.set_value("display", "window_type", 0)
		config_settings.set_value("display", "borderless", false)
		config_settings.set_value("display", "barbie_mode", false)
		
		# Video
		config_settings.set_value("video", "brightness", 1.0)
		config_settings.set_value("video", "sky_brightness", 1.0)
		config_settings.set_value("video", "glow", true)
		config_settings.set_value("video", "glow_strength", 1.3)
		config_settings.set_value("video", "occlusion_culling", false)
		config_settings.set_value("video", "anisotropic", 0)
		config_settings.set_value("video", "soft_shadow", 2)
		config_settings.set_value("video", "ssao", true)
		config_settings.set_value("video", "ssao_option", 2)
		config_settings.set_value("video", "ssil", false)
		config_settings.set_value("video", "ssil_option", 2)
		config_settings.set_value("video", "msaa", 2)
		config_settings.set_value("video", "taa", false)
		config_settings.set_value("video", "ssr", false)
		
		# Audio
		config_settings.set_value("audio", "master", 1.0)
		config_settings.set_value("audio", "respawn", 1.0)
		config_settings.set_value("audio", "guns", 1.0)
		config_settings.set_value("audio", "kill_effects", 1.0)
		config_settings.set_value("audio", "death", 1.0)
		config_settings.set_value("audio", "end", 1.0)
		config_settings.set_value("audio", "footsteps", 1.0)
		
		config_settings.save(Global.SETTINGS_FILE_PATH)
	else:
		config_settings.load(Global.SETTINGS_FILE_PATH)
	
	# Player
	if !FileAccess.file_exists(Global.PLAYER_FILE_PATH):
		config_player.set_value("player", "username", "Newbie")
		config_player.set_value("player", "quote", "I didn't change my quote bleh")
		config_player.set_value("player", "color", Color("00aa00"))
		
		# Accessories
		config_player.set_value("accessories", "hat", 0)
		config_player.set_value("accessories", "face", 0)
		
		config_player.save(Global.PLAYER_FILE_PATH)
	else:
		config_player.load(Global.PLAYER_FILE_PATH)


#region Settings
func save_camera_setting(key, value) -> void:
	config_settings.set_value("camera", key, value)
	config_settings.save(Global.SETTINGS_FILE_PATH)

func load_camera_setting() -> Dictionary:
	var camera_settings = {}
	for key in config_settings.get_section_keys("camera"):
		camera_settings[key] = config_settings.get_value("camera", key)
	
	return camera_settings


func save_display_setting(key, value) -> void:
	config_settings.set_value("display", key, value)
	config_settings.save(Global.SETTINGS_FILE_PATH)

func load_display_setting() -> Dictionary:
	var display_settings = {}
	for key in config_settings.get_section_keys("display"):
		display_settings[key] = config_settings.get_value("display", key)
	
	return display_settings


func save_video_setting(key, value) -> void:
	config_settings.set_value("video", key, value)
	config_settings.save(Global.SETTINGS_FILE_PATH)

func load_video_setting() -> Dictionary:
	var video_settings = {}
	for key in config_settings.get_section_keys("video"):
		video_settings[key] = config_settings.get_value("video", key)
	
	return video_settings


func save_audio_setting(key, value) -> void:
	config_settings.set_value("audio", key, value)
	config_settings.save(Global.SETTINGS_FILE_PATH)

func load_audio_setting() -> Dictionary:
	var audio_settings = {}
	for key in config_settings.get_section_keys("audio"):
		audio_settings[key] = config_settings.get_value("audio", key)
	
	return audio_settings
#endregion

#region Player
func save_player_setting(key, value) -> void:
	config_player.set_value("player", key, value)
	config_player.save(Global.PLAYER_FILE_PATH)

func load_player_setting() -> Dictionary:
	var player_settings = {}
	for key in config_player.get_section_keys("player"):
		player_settings[key] = config_player.get_value("player", key)
	
	return player_settings


func save_accessories_setting(key, value) -> void:
	config_player.set_value("accessories", key, value)
	config_player.save(Global.PLAYER_FILE_PATH)

func load_accessories_setting() -> Dictionary:
	var accessories_settings = {}
	for key in config_player.get_section_keys("accessories"):
		accessories_settings[key] = config_player.get_value("accessories", key)
	
	return accessories_settings

#endregion

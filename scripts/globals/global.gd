extends Node

const SETTINGS_FILE_PATH = "user://settings.ini"
const PLAYER_FILE_PATH = "user://player_data.ini"
const PORT = 9999
const WEAPON_SCENES = [
	"res://scenes/weapons/pistol.tscn", # Pistol scene
	"res://scenes/weapons/sniper_rifle.tscn", # Sniper rifle scene
	"res://scenes/weapons/assault_rifle.tscn", # Assault rifle scene
	"res://scenes/weapons/deagle.tscn", # Desert eagle scene
	"res://scenes/weapons/ak_67.tscn", # AK67 scene
	
	# Golden Guns
	"res://scenes/weapons/golden_gun.tscn", # Golden gun scene
	"res://scenes/weapons/golden_sniper.tscn" # Golden sniper rifle scene
]
const RESOLUTIONS = [
	"640×360",
	"640×480",
	"800×600",
	"1024×768",
	"1280×720",
	"1280×800",
	"1600×900",
	"1920×1080",
	"1920×1200",
	"2560×1440",
	"2560×1600",
	"2560×1080"
]
const MAPS = [
	"res://scenes/maps/dm_grey.tscn", # DM_GREY [0]
	"res://scenes/maps/dm_matrix.tscn", # DM_MATRIX [1]
]
const MAPS_STRINGS = [
	"dm_grey",
	"dm_matrix",
]
const GAMEMODES = [
	"Randomizer",
	"Competitive",
	"Standard"
]
const HAT_ACCESSORIES = [
	"res://scenes/accessories/turtle.tscn", # TURTLE HAT [0]
	"res://common/models/accessories/TopHat.blend", # TOP HAT [1]
]
const FACE_ACCESSORIES = [
	"res://common/models/accessories/Eyes.blend", # EYES FACE [0]
	"res://common/models/accessories/Mustache.blend", # MUSTACHE FACE [1]
	"res://common/models/accessories/Sunglasses.blend", # SUNGLASSES FACE [2]
]

var is_in_game : bool = false
var arguments : Dictionary = {}
var sensitivity : Vector2 = Vector2(2.0, 2.0)
var fov : int = 80

# For settings
var brightness : float = 1.0
var sky_brightness : float = 1.0
var glow : float = 1.3
var is_glow : bool = true
var ssao_index : int = 2
var is_ssao : bool = true
var ssil_index : int = 2
var is_ssil : bool = true
var is_ssr : bool = false

# Audio busses
var master_idx = AudioServer.get_bus_index("Master")
var respawn_sounds_idx = AudioServer.get_bus_index("RespawnSounds")
var gun_sfx_idx = AudioServer.get_bus_index("GunSFX")
var kill_effects_idx = AudioServer.get_bus_index("KillEffectsSound")
var death_idx = AudioServer.get_bus_index("DeathSound")


func _ready() -> void: ## !!! Important shit !!!
	ConfigFileHandler.load_configs()
	
	# Loading these settings
	load_settings()


func change_scene_with_arguments(scene_path, args = {}) -> void:
	arguments = args
	
	get_tree().change_scene_to_file(scene_path)
	
	if get_tree().current_scene == null:
		await get_tree().node_added
	await get_tree().current_scene.ready
	
	update_everything() # Updating everything if all needed nodes exist


#region Loading settings
func load_settings():
	_load_camera_settings()
	_load_display_settings()
	_load_video_settings()
	_load_audio_settings()
	
	update_everything() # Updating everything if all needed nodes exist


func update_everything() -> void:
	_update_brightness()
	_update_sky_brightness()
	_update_glow()
	_update_SSAO()
	_update_SSIL()
	_update_SSR()


func _load_camera_settings() -> void:
	# Loading camera's settings
	var camera_settings = ConfigFileHandler.load_camera_setting()
	
	sensitivity = Vector2(camera_settings.sensitivity, camera_settings.sensitivity)
	fov = camera_settings.fov


func _load_display_settings() -> void:
	# Loading display's settings
	var display_settings = ConfigFileHandler.load_display_setting()
	
	var window_type = display_settings.window_type
	match window_type:
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	var resolution_id = display_settings.resolution
	var new_resolution = RESOLUTIONS[resolution_id].split("×")
	var new_size = Vector2i(int(new_resolution[0]), int(new_resolution[1]))
	DisplayServer.window_set_size(new_size)
	
	var fps = display_settings.fps
	Engine.max_fps = fps
	
	var vsync = display_settings.vsync
	match vsync:
		false:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		true:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	
	var borderless = display_settings.borderless
	ConfigFileHandler.save_display_setting("borderless", borderless)
	
	#var barbie_mode = display_settings.barbie_mode
	# TODO


func _load_video_settings() -> void:
	# Loading video's settings
	var video_settings = ConfigFileHandler.load_video_setting()
	
	# Settings for world envi
	brightness = video_settings.brightness
	sky_brightness = video_settings.sky_brightness
	glow = video_settings.glow_strength
	is_glow = video_settings.glow
	ssao_index = video_settings.ssao_option
	is_ssao = video_settings.ssao
	ssil_index = video_settings.ssil_option
	is_ssil = video_settings.ssil
	is_ssr = video_settings.ssr
	
	var occlusion_culling = video_settings.occlusion_culling
	ProjectSettings.set_setting("rendering/occlusion_culling/use_occlusion_culling", occlusion_culling)
	
	var anisotropic = video_settings.anisotropic
	ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", anisotropic)
	
	var soft_shadow_index = video_settings.soft_shadow
	var soft_shadow_list = [
		"Fastest",
		"Faster",
		"Fast",
		"Average",
		"Slow",
		"Slowest"
	]
	var soft_shadow = soft_shadow_list[soft_shadow_index]
	if "Fastest" == soft_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
	elif "Faster" == soft_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
	elif "Fast" == soft_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	elif "Average" == soft_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	elif "Slow" == soft_shadow:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	else:
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
	
	var msaa_index = video_settings.msaa
	var msaa_list = [
		"Fastest",
		"Average",
		"Slow",
		"the other option I forgor its name lmao"
	]
	var msaa = msaa_list[msaa_index]
	if "Fastest" in msaa:
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif "Average" in msaa:
		get_viewport().msaa_3d = Viewport.MSAA_2X
	elif "Slow" in msaa:
		get_viewport().msaa_3d = Viewport.MSAA_4X
	else:
		get_viewport().msaa_3d = Viewport.MSAA_8X
	
	var taa = video_settings.taa
	get_viewport().use_taa = taa


func _load_audio_settings() -> void:
	# Loading audio's settings
	var audio_settings = ConfigFileHandler.load_audio_setting()
	
	AudioServer.set_bus_volume_db(master_idx, linear_to_db(audio_settings.master))
	AudioServer.set_bus_volume_db(respawn_sounds_idx, linear_to_db(audio_settings.respawn))
	AudioServer.set_bus_volume_db(gun_sfx_idx, linear_to_db(audio_settings.guns))
	AudioServer.set_bus_volume_db(kill_effects_idx, linear_to_db(audio_settings.kill_effects))
	AudioServer.set_bus_volume_db(death_idx, linear_to_db(audio_settings.death))
#endregion


func _update_sensitivity() -> void:
	var main_scene = get_tree().current_scene
	var id = multiplayer.get_unique_id()
	var player = main_scene.players_folder.get_node_or_null(str(id))
	
	if player == null: return
	
	player.first_person_camera.update_mouse_sensitivity(sensitivity)

func _update_fov() -> void:
	var main_scene = get_tree().current_scene
	var id = multiplayer.get_unique_id()
	var player = main_scene.players_folder.get_node_or_null(str(id))
	
	if player == null: return
	
	player.player_fov = fov

func _update_brightness() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	if world_env == null: return
	
	world_env.environment.adjustment_brightness = brightness

func _update_sky_brightness() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	if world_env == null: return
	
	world_env.environment.background_energy_multiplier = sky_brightness

func _update_glow() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	if world_env == null: return
	
	world_env.environment.glow_enabled = is_glow
	
	world_env.environment.glow_strength = glow

func _update_SSAO() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	if world_env == null: return
	
	world_env.environment.ssao_enabled = is_ssao
	
	ProjectSettings.set_setting("rendering/environment/ssao/quality", ssao_index)

func _update_SSIL() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	if world_env == null: return
	
	world_env.environment.ssil_enabled = is_ssao
	
	ProjectSettings.set_setting("rendering/environment/ssil/quality", ssil_index)

func _update_SSR() -> void:
	var main_scene = get_tree().current_scene
	var world_env : WorldEnvironment = main_scene.get_node_or_null("WorldEnvironment")
	
	if world_env == null: return
	
	world_env.environment.ssr_enabled = is_ssr

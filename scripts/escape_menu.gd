extends Control

@onready var left_panel: PanelContainer = $LeftPanel
@onready var settings: PanelContainer = $Settings
@onready var left_panel_animations: AnimationPlayer = $LeftPanelAnimations
@onready var settings_animations: AnimationPlayer = $SettingsAnimations


var is_in_menu : bool = false
var is_in_settings : bool = false


func _ready() -> void:
	left_panel_animations.play("RESET")
	settings_animations.play("RESET")
	
	left_panel.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	settings.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED


func _physics_process(_delta: float) -> void:
	# Setting up variables
	is_in_menu = left_panel.is_in_menu
	is_in_settings = left_panel.is_in_settings


# Left panel
func _on_left_panel_open() -> void:
	left_panel.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
	left_panel_animations.play("open")


func _on_left_panel_close() -> void:
	left_panel.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	left_panel_animations.play("close")


# Settings
func _on_left_panel_settings_open() -> void:
	settings.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
	settings_animations.play("open")


func _on_left_panel_settings_close() -> void:
	settings.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	settings_animations.play("close")

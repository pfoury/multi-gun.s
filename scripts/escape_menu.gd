extends PanelContainer

var is_in_menu : bool = false


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		is_in_menu = !is_in_menu


func _on_resume_button_pressed() -> void:
	is_in_menu = false


func _on_settings_button_pressed() -> void:
	pass # Replace with settings scene


func _on_main_menu_button_pressed() -> void:
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()

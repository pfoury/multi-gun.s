extends PanelContainer

signal close
signal open
signal settings_open
signal settings_close

var is_in_menu : bool = false
var is_in_settings : bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		is_in_menu = !is_in_menu
		
		if is_in_menu:
			open.emit()
		else:
			close.emit()
			
			if is_in_settings:
				settings_close.emit()
				is_in_settings = false


func _on_resume_button_pressed() -> void:
	close.emit()
	is_in_menu = false
	
	if is_in_settings:
		settings_close.emit()
		is_in_settings = false


func _on_settings_button_pressed() -> void:
	is_in_settings = !is_in_settings
	
	if is_in_settings:
		settings_open.emit()
	else:
		settings_close.emit()


func _on_main_menu_button_pressed() -> void:
	if multiplayer.get_unique_id() == 1:
		Server.kick_everyone()
		
		# Waiting for everyone to leave
		var main = get_tree().current_scene
		while len(main.player_list) != 1:
			await get_tree().process_frame
	
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()

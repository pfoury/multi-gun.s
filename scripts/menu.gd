extends PanelContainer

var main : Node


func _on_deploy_button_pressed() -> void:
	main = get_tree().current_scene
	main.is_deploy = true
	hide()
	main.close_button.show()
	main.camera_player.play("deploy_start")

func _on_customization_button_pressed() -> void:
	main = get_tree().current_scene
	main.is_customize = true
	hide()
	main.close_button.show()
	main.customization.show()
	main.camera_player.play("customization_start")

func _on_settings_button_pressed() -> void:
	main = get_tree().current_scene
	hide()
	main.close_button.show()

func _on_about_button_pressed() -> void:
	main = get_tree().current_scene
	hide()
	main.close_button.show()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

extends PanelContainer


@onready var quote_text_edit: TextEdit = $MarginContainer/VBoxContainer/VBoxContainer/Quote/TextEdit
@onready var username_line_edit: LineEdit = $MarginContainer/VBoxContainer/VBoxContainer/Username/LineEdit


var main : Node
var args : Dictionary


func _load_player_customization_settings() -> void:
	main = get_tree().current_scene
	args = main.args
	
	username_line_edit.text = args["username"]
	username_line_edit.placeholder_text = args["username"]
	
	quote_text_edit.text = args["quote"]
	quote_text_edit.placeholder_text = args["quote"]


func _on_username_line_edit_text_submitted(new_text: String) -> void:
	var old_text = username_line_edit.placeholder_text
	
	if (len(new_text) < 4 or len(new_text) > 20):
		new_text = old_text
	
	username_line_edit.text = new_text
	username_line_edit.placeholder_text = new_text
	
	args["username"] = new_text
	ConfigFileHandler.save_player_setting("username", new_text)

func _on_quote_text_edit_text_changed() -> void:
	var new_text = quote_text_edit.text
	var old_text = quote_text_edit.placeholder_text
	
	if len(new_text) > 120:
		new_text = old_text
		quote_text_edit.text = new_text
	quote_text_edit.placeholder_text = new_text
	
	args["quote"] = new_text
	ConfigFileHandler.save_player_setting("quote", new_text)

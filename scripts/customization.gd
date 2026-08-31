extends PanelContainer


# Accessories
@onready var hat_option_button: OptionButton = $MarginContainer/VBoxContainer/Accessories/VBoxContainer/HatAccessory/OptionButton
@onready var face_option_button: OptionButton = $MarginContainer/VBoxContainer/Accessories/VBoxContainer/FaceAccessory/OptionButton

# Color
@onready var red_h_slider: HSlider = $MarginContainer/VBoxContainer/Color/VBoxContainer/Sliders/Red/HSlider
@onready var red_line_edit: LineEdit = $MarginContainer/VBoxContainer/Color/VBoxContainer/Sliders/Red/LineEdit

@onready var green_h_slider: HSlider = $MarginContainer/VBoxContainer/Color/VBoxContainer/Sliders/Green/HSlider
@onready var green_line_edit: LineEdit = $MarginContainer/VBoxContainer/Color/VBoxContainer/Sliders/Green/LineEdit

@onready var blue_h_slider: HSlider = $MarginContainer/VBoxContainer/Color/VBoxContainer/Sliders/Blue/HSlider
@onready var blue_line_edit: LineEdit = $MarginContainer/VBoxContainer/Color/VBoxContainer/Sliders/Blue/LineEdit

@onready var hex_line_edit: LineEdit = $MarginContainer/VBoxContainer/Color/VBoxContainer/MarginContainer/HEXColor/LineEdit

var hats_node : Node3D
var faces_node : Node3D
var main : Node
var args : Dictionary


func _load_customization_settings() -> void:
	main = get_tree().current_scene
	args = main.args
	
	hats_node = main.accessory_pivot.get_node("Hats")
	faces_node = main.accessory_pivot.get_node("Faces")
	
	# Hiding every accessory
	for child in hats_node.get_children():
		child.hide()
	for child in faces_node.get_children():
		child.hide()
	
	_update_color()
	_update_accessories()



#region Colors
func _update_color() -> void:
	var color_text : String = args["color"].to_html(false)
	var red : int = int(255 * args["color"][0])
	var green : int = int(255 * args["color"][1])
	var blue : int = int(255 * args["color"][2])
	
	hex_line_edit.text = color_text.to_upper()
	
	red_h_slider.value = red
	red_line_edit.text = str(red)
	
	green_h_slider.value = green
	green_line_edit.text = str(green)
	
	blue_h_slider.value = blue
	blue_line_edit.text = str(blue)


# Red
func _on_red_h_slider_value_changed(value: float) -> void:
	red_h_slider.value = value
	
	var green : float = args["color"][1]
	var blue : float = args["color"][2]
	
	var new_color : Color = Color(value / 255, green, blue)
	main.player_mesh.mesh.material.albedo_color = new_color
	
	args["color"] = new_color
	hex_line_edit.text = new_color.to_html(false).to_upper()
	
	ConfigFileHandler.save_player_setting("color", new_color)

func _on_red_line_edit_text_changed(new_text: String) -> void:
	if !new_text.is_valid_int() or len(new_text) > 1 and new_text[0] == "0":
		red_line_edit.text = str(int(red_line_edit.placeholder_text))
	else:
		var value : int = int(new_text)
		
		if value < 0:
			value = 0
		elif value > 255:
			value = 255
		
		red_line_edit.text = str(value)
		
		_on_red_h_slider_value_changed(value)


# Green
func _on_green_h_slider_value_changed(value: float) -> void:
	green_h_slider.value = value
	
	var red : float = args["color"][0]
	var blue : float = args["color"][2]
	
	var new_color : Color = Color(red, value / 255, blue)
	main.player_mesh.mesh.material.albedo_color = new_color
	
	args["color"] = new_color
	hex_line_edit.text = new_color.to_html(false).to_upper()
	
	ConfigFileHandler.save_player_setting("color", new_color)

func _on_green_line_edit_text_changed(new_text: String) -> void:
	if !new_text.is_valid_int() or len(new_text) > 1 and new_text[0] == "0":
		green_line_edit.text = str(int(green_line_edit.placeholder_text))
	else:
		var value : int = int(new_text)
		
		if value < 0:
			value = 0
		elif value > 255:
			value = 255
		
		green_line_edit.text = str(value)
		
		_on_green_h_slider_value_changed(value)


# Blue
func _on_blue_h_slider_value_changed(value: float) -> void:
	blue_h_slider.value = value
	
	var green : float = args["color"][1]
	var red : float = args["color"][0]
	
	var new_color : Color = Color(red, green, value / 255)
	main.player_mesh.mesh.material.albedo_color = new_color
	
	args["color"] = new_color
	hex_line_edit.text = new_color.to_html(false).to_upper()
	
	ConfigFileHandler.save_player_setting("color", new_color)

func _on_blue_line_edit_text_changed(new_text: String) -> void:
	if !new_text.is_valid_int() or len(new_text) > 1 and new_text[0] == "0":
		blue_line_edit.text = str(int(blue_line_edit.placeholder_text))
	else:
		var value : int = int(new_text)
		
		if value < 0:
			value = 0
		elif value > 255:
			value = 255
		
		blue_line_edit.text = str(value)
		
		_on_blue_h_slider_value_changed(value)


# HEX
func _on_hex_line_edit_text_submitted(new_text: String) -> void:
	var new_color : Color
	if len(hex_line_edit.text) != 6:
		new_color = Color(randf(), randf(), randf())
	else:
		new_color = Color(new_text)
	args["color"] = new_color
	
	ConfigFileHandler.save_player_setting("color", new_color)
	main.player_mesh.mesh.material.albedo_color = new_color
	hex_line_edit.text = new_color.to_html(false).to_upper()
#endregion


#region Accessories
func _update_accessories() -> void:
	hat_option_button.select(args["hat"])
	face_option_button.select(args["face"])
	
	_on_hat_option_button_item_selected(args["hat"])
	_on_face_option_button_item_selected(args["face"])


func _on_hat_option_button_item_selected(index: int) -> void:
	var old_item = args["hat"]
	
	# Hiding the previous accessory
	if old_item != 0:
		hats_node.get_child(old_item - 1).hide()
	
	# Showing the new one
	if index != 0:
		hats_node.get_child(index - 1).show()
	
	args["hat"] = index
	ConfigFileHandler.save_accessories_setting("hat", index)

func _on_face_option_button_item_selected(index: int) -> void:
	var old_item = args["face"]
	
	# Hiding the previous accessory
	if old_item != 0:
		faces_node.get_child(old_item - 1).hide()
	
	# Showing the new one
	if index != 0:
		faces_node.get_child(index - 1).show()
	
	args["face"] = index
	ConfigFileHandler.save_accessories_setting("face", index)

#endregion

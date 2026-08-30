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

@onready var hex_line_edit: LineEdit = $MarginContainer/VBoxContainer/Color/VBoxContainer/HEXColor/LineEdit


var main : Node
var args : Dictionary


func _load_customization_settings() -> void:
	main = get_tree().current_scene
	
	args = main.args
	
	_update_color()
	_update_accessories()


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

func _update_accessories() -> void:
	hat_option_button.select(args["hat"])
	face_option_button.select(args["face"])

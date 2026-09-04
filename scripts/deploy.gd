extends PanelContainer

# Containers
@onready var join_container: VBoxContainer = $MarginContainer/VBC/MarginContainer/JoinContainer
@onready var host_container: VBoxContainer = $MarginContainer/VBC/MarginContainer/HostContainer
# Options
@onready var map_option_button: OptionButton = $MarginContainer/VBC/MarginContainer/HostContainer/MapAndGamemode/Map/OptionButton
@onready var gamemode_option_button: OptionButton = $MarginContainer/VBC/MarginContainer/HostContainer/MapAndGamemode/Gamemode/OptionButton
# Line Edit
@onready var ip_line_edit: LineEdit = $MarginContainer/VBC/MarginContainer/JoinContainer/IPLineEdit
@onready var score_line_edit: LineEdit = $MarginContainer/VBC/MarginContainer/HostContainer/ScoreGoal/LineEdit

func _on_join_show_button_pressed() -> void:
	join_container.show()
	host_container.hide()


func _on_host_show_button_pressed() -> void:
	join_container.hide()
	host_container.show()


func _on_host_pressed() -> void:
	var main = get_tree().current_scene
	
	# Setting up host
	main.args["peer"] = "host"
	main.change_scene()


func _on_join_pressed() -> void:
	var main = get_tree().current_scene
	
	# Setting up client
	main.args["peer"] = "client"
	if ip_line_edit.text == "":
		main.args["ip"] = "localhost"
	else:
		main.args["ip"] = ip_line_edit.text
	main.change_scene()


func _on_map_option_button_item_selected(index: int) -> void:
	var main = get_tree().current_scene
	
	var map = map_option_button.get_item_text(index)
	if map == "Pick Random":
		map = Global.MAPS_STRINGS.pick_random()
	
	main.args["map"] = map

func _on_gamemode_option_button_item_selected(index: int) -> void:
	var main = get_tree().current_scene
	
	var gm = gamemode_option_button.get_item_text(index)
	if gm == "Pick Random":
		gm = Global.GAMEMODES.pick_random()
	
	main.args["gm"] = gm


func _on_score_goalline_edit_text_submitted(new_text: String) -> void:
	var main = get_tree().current_scene
	
	var old_text = score_line_edit.placeholder_text
	
	if !new_text.is_valid_int() or int(new_text) < 1:
		new_text = old_text
	
	score_line_edit.placeholder_text = new_text
	score_line_edit.text = new_text
	
	main.args["scoregoal"] = int(new_text)

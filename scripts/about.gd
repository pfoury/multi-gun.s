extends PanelContainer

# Containers
@onready var resources: VBoxContainer = $MarginContainer/HBoxContainer/TextContainer/Resources
@onready var fonts: VBoxContainer = $MarginContainer/HBoxContainer/TextContainer/Fonts
@onready var author: VBoxContainer = $MarginContainer/HBoxContainer/TextContainer/Author
# Texts
@onready var geologica_text: RichTextLabel = $MarginContainer/HBoxContainer/TextContainer/Fonts/Texts/GeologicaText
@onready var oswald_text: RichTextLabel = $MarginContainer/HBoxContainer/TextContainer/Fonts/Texts/OswaldText


func _on_resources_button_pressed() -> void:
	resources.show()
	fonts.hide()
	author.hide()


func _on_fonts_button_pressed() -> void:
	resources.hide()
	fonts.show()
	author.hide()


func _on_author_button_pressed() -> void:
	resources.hide()
	fonts.hide()
	author.show()


func _on_geologica_pressed() -> void:
	geologica_text.show()
	oswald_text.hide()


func _on_oswald_pressed() -> void:
	geologica_text.hide()
	oswald_text.show()

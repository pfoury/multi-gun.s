extends MarginContainer

const SPEED_DOWN : int = 30
const SPEED_UP : int = 30

@onready var donators_label: RichTextLabel = $PC/MC/VBC/ScrollContainer/PanelContainer/DonatorsLabel
@onready var scroll_container: ScrollContainer = $PC/MC/VBC/ScrollContainer


func _ready():
	pass

func _process(delta):
	if scroll_container != null:
		scroll_container.scroll_vertical += SPEED_DOWN * delta
		
		print(scroll_container.get_v_scroll())

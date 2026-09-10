extends MarginContainer

const MAX_NAME_LENGHT : int = 14
const DONATORS_PER_PAGE : int = 6
const TIERS_EFFECTS : Dictionary = {
	"Мини-Поддержка": "Мини-поддержка",
	"Поддержка": "[wave amp=30 freq=5 speed=3 ease=-2.0]Поддержка[/wave]",
	"МЕГАПоддержка": "[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]МЕГАподдержка[/rainbow]",
}

@onready var donators_names_label: RichTextLabel = $PC/MC/VBC/VBC/DonatorsContainer/MC/HBC/DonatorsUsername
@onready var donators_tiers_label: RichTextLabel = $PC/MC/VBC/VBC/DonatorsContainer/MC/HBC/DonatorsTiers
@onready var page_label: RichTextLabel = $PC/MC/VBC/VBC/PageLabel
@onready var swipe_page_timer: Timer = $SwipePageTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var donators_names : Array = []
var donators_tiers : Array = []
var pages_amount : int = 1
var current_page : int = 1

func _ready() -> void:
	animation_player.play("fade_in")
	animation_player.stop()
	
	get_data_from_url()


func get_data_from_url() -> void:
	var url = "http://162.248.165.236:6769/supporters.json"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(_on_request_completed)
	
	var error = http_request.request(url)
	if error != OK:
		_on_received_error()


func _on_received_error() -> void:
	animation_player.play("fade_in")
	
	donators_names_label.text = "Error :("
	donators_tiers_label.text = "Error :("


func _on_request_completed(_result, response_code, _headers, body) -> void:
	if response_code != 200:
		_on_received_error()
		return
	
	animation_player.play("fade_in")
	
	# Getting and sorting donators
	var donators : Array = JSON.parse_string(body.get_string_from_utf8())
	donators.sort_custom(func(a, b): return a["paid"] > b["paid"])
	
	# Working with each donator's dictionary
	for donator in donators:
		var donator_name : String = donator["name"]
		if len(donator_name) > MAX_NAME_LENGHT:
			donator_name = donator_name.substr(0, MAX_NAME_LENGHT) + "..."
		
		var donator_tier : String = donator["level"]
		
		donators_names.append(donator_name)
		donators_tiers.append(TIERS_EFFECTS[donator_tier])
	
	# Test variables
	#donators_names = [
		#"donator1",
		#"donator2",
		#"donator3",
		#"donator4",
		#"donator5",
		#"donator6",
		#"donator7",
		#"donator8",
	#]
	#donators_tiers = [
		#"[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]МЕГАподдержка[/rainbow]",
		#"[wave amp=30 freq=5 speed=3 ease=-2.0]Поддержка[/wave]",
		#"[wave amp=30 freq=5 speed=3 ease=-2.0]Поддержка[/wave]",
		#"Мини-поддержка",
		#"Мини-поддержка",
		#"[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]МЕГАподдержка[/rainbow]",
		#"Мини-поддержка",
		#"[wave amp=30 freq=5 speed=3 ease=-2.0]Поддержка[/wave]",
	#]
	
	pages_amount = floor(len(donators_names) / str(DONATORS_PER_PAGE).to_float()) + 1
	
	_changing_labels()
	
	if pages_amount != 1:
		swipe_page_timer.start()


func _changing_labels() -> void:
	var amount_of_donators = len(donators_names) - DONATORS_PER_PAGE * (current_page - 1)
	
	# Getting start and end points
	var start_donator = DONATORS_PER_PAGE * (current_page - 1)
	var last_donator = start_donator + DONATORS_PER_PAGE
	if amount_of_donators <= DONATORS_PER_PAGE:
		last_donator = len(donators_names)
	
	# Setting up everything..
	donators_names_label.text = ""
	donators_tiers_label.text = ""
	
	# Working with each donator
	var idx = start_donator
	while idx < last_donator:
		var donator_name : String = donators_names[idx]
		var donator_tier : String = donators_tiers[idx]
		
		donators_names_label.text += donator_name + "\n"
		donators_tiers_label.text += donator_tier + "\n"
		
		idx += 1
	
	# Changing page label
	page_label.text = str(current_page) + "/" + str(pages_amount)


func _on_swipe_page_timer_timeout() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	current_page += 1
	if current_page > pages_amount:
		current_page = 1
	
	_changing_labels()
	
	animation_player.play("fade_in")
	await animation_player.animation_changed
	
	swipe_page_timer.start()

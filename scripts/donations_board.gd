extends MarginContainer

const MAX_NAME_LENGHT : int = 15
const DONATORS_PER_PAGE : int = 6
const TIERS_EFFECTS : Dictionary = {
	"Мини-Поддержка": "Мини-поддержка",
	"Поддержка": "[wave amp=30 freq=5 speed=3 ease=-2.0]Поддержка[/wave]",
	"МЕГАПоддержка": "[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]МЕГАподдержка[/rainbow]",
}

@onready var donators_names_label: RichTextLabel = $PC/MC/VBC/DonatorsContainer/MC/HBC/DonatorsUsername
@onready var donators_tiers_label: RichTextLabel = $PC/MC/VBC/DonatorsContainer/MC/HBC/DonatorsTiers
@onready var swipe_page_timer: Timer = $SwipePageTimer

var donators_names : Array = []
var donators_tiers : Array = []
var pages_amount : int = 1
var current_page : int = 1


func _ready() -> void:
	get_data_from_url()


func get_data_from_url() -> void:
	var url = "http://162.248.165.236:6769/supporters.json"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(_on_request_completed)
	
	var error = http_request.request(url)
	if error != OK:
		_on_received_error()


func _on_received_error() -> void: # TODO
	print("unlucky")


func _on_request_completed(result, response_code, headers, body) -> void:
	if response_code != 200:
		_on_received_error()
		return
	
	# Getting and sorting donators
	var donators : Array = JSON.parse_string(body.get_string_from_utf8())
	donators.sort_custom(func(a, b): return a["paid"] > b["paid"])
	
	# Working with each donator's dictionary
	for donator in donators:
		var name : String = donator["name"]
		if len(name) > MAX_NAME_LENGHT:
			name = name.substr(0, MAX_NAME_LENGHT) + "..."
		
		var tier : String = donator["level"]
		
		donators_names.append(name)
		donators_tiers.append(TIERS_EFFECTS[tier])

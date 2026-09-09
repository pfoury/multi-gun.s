extends MarginContainer

const MAX_LENGHT : int = 15
const DONATORS_PER_PAGE : int = 6
const TIERS_EFFECTS : Dictionary = {
	"Мини-поддержка": "Мини-поддержка",
	"Поддержка": "[wave amp=30 freq=5 speed=3 ease=-2.0]Поддержка[/wave]",
	"Мега-поддержка": "[rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]МЕГАподдержка[/rainbow]",
}

@onready var donators_label: RichTextLabel = $PC/MC/VBC/DonatorsContainer/MC/HBC/DonatorsUsername
@onready var donators_tiers: RichTextLabel = $PC/MC/VBC/DonatorsContainer/MC/HBC/DonatorsTiers


func get_data_from_url() -> void:
	var url = "http://162.248.165.236:6769/supporters.json"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	# Сигнал сработает, когда данные будут получены
	http_request.request_completed.connect(_on_request_completed)
	
	# Отправляем GET-запрос
	var error = http_request.request(url)
	if error != OK:
		_on_received_error()


func _on_received_error() -> void:
	print("unlucky")


func _on_request_completed(result, response_code, headers, body) -> void:
	print(result)

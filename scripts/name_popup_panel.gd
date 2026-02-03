extends PopupPanel

signal name_confirmed(player_name: String)

@onready var name_input: LineEdit = $PanelContainer/VBoxContainer/NameInput
@onready var random_button: Button = $PanelContainer/VBoxContainer/ButtonRow/RandomizeButton
@onready var confirm_button: Button = $PanelContainer/VBoxContainer/ButtonRow/ConfirmButton

func _ready():
	name_input.text = ""

func _on_random_pressed():
	name_input.text = _generate_default_name()

func _on_confirm_pressed():
	var name := name_input.text.strip_edges()
	
	if name == "":
		name = _generate_default_name()
	emit_signal("name_confirmed", name)
	hide()

func _generate_default_name() -> String:
	var adjectives = ["Swift", "Silent", "Lucky", "Crazy", "Falling"]
	var nouns = ["Bird", "Cube", "Pilot", "Rocket", "Missile"]
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	return "%s%s" % [
		adjectives[rng.randi_range(0, adjectives.size() - 1)],
		nouns[rng.randi_range(0, nouns.size() - 1)]
	]

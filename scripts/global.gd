extends Node

var score := 0
var player_id := ""
var player_name := ""

var save_path := "user://savegame.json"

func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		print("✅ Game Saved")

func load_game() -> Dictionary:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		var result = JSON.parse_string(content)
		if typeof(result) == TYPE_DICTIONARY:
			print("✅ Game Loaded")
			return result
	print("⚠️ No save file found or data is corrupted.")
	return {}  # default fallback

func save_game_data():
	var data = {
		"player_id": player_id,
		"player_name": player_name,
		"score": score
	}
	save_game(data)
	print("💾 Global data saved:", data)

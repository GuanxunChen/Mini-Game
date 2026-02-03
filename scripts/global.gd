extends Node

var GM_mode = true
var current_score := 0
var highscore := 0
var player_id := ""
var player_name := ""

var save_path := "user://savegame.json"

var last_login_date = ""
var was_data_loaded = false

#func should_show_daily_login() -> bool:
#	var last_login = Global.last_login_date  # however you store it
#	var current_date = Time.get_date_string_from_system()
#
#	if last_login != current_date:
#		Global.last_login_date = current_date
#		Global.save_game_data()
#		return true
#	return false

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
	#need to be encoded
	var data = {
		"player_id": player_id,
		"player_name": player_name,
		"score": highscore,
		"last_login_date": last_login_date
	}
	save_game(data)
	print("💾 Global data saved:", data)

func load_data():
	#need to be decoded
	if was_data_loaded:
		print("🟡 Data already loaded, skipping.")
		return
	var data := load_game()
	if data:
		player_name = data.get("player_name", "~")
		player_id = data.get("player_id", "")
		highscore = data.get("score", 0)
		was_data_loaded = true
		last_login_date = data.get("last_login_date", "")
		print("✅ Global data loaded:", data)

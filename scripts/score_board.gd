extends Node2D

signal retry_request
signal main_menu

@onready var name_popup = $CanvasLayer/NamePopUp
@onready var top_3_container = $CanvasLayer/Control/PanelContainer/VBoxContainer/score_container/Top3Container
@onready var scroll_container = $CanvasLayer/Control/PanelContainer/VBoxContainer/score_container/VBoxContainer/ScrollContainer

@onready var submit_score_button := $CanvasLayer/submit_score
@onready var http: HTTPRequest = $HTTPRequest

const WINDOW_SIZE := 25
var last_request_type := ""
var score_list := []

# 引入 Firebase 配置
const FirebaseConfig = preload("res://addons/firebase/config.gd")

#临时写死的用户ID
var user_id := Global.player_id

func _ready():
	name_popup.name_confirmed.connect(_on_name_confirmed)
	http.request_completed.connect(_on_request_completed)
	fetch_top_scores()

func _on_name_confirmed(player_name: String):
	Global.player_name = player_name
	Global.save_game_data()
	#print("Name confirmed:", player_name)
	submit_score()

func _process_leaderboard(raw: Dictionary) -> void:		
	#dictionary数据转array
	score_list = []
	
	for uid in raw.keys():
		var e = raw[uid]
		if e is Dictionary and e.has("score"):
			score_list.append({
				"uid": uid,
				"name": e.name,
				"score": int(e.score),
				"ts": int(e.get("timestamp", 0))
			})
	print("score_list: ")
	print(score_list)
	
	#分数降序，同分时间早
	score_list.sort_custom(func(a, b):
		if a.score == b.score:
			return a.ts < b.ts
		return a.score > b.score
	)

	#找自己排名
	var my_index := -1
	for i in score_list.size():
		if score_list[i].uid == Global.player_id:
			my_index = i
			break

	#构造显示文本
	var top3 = $CanvasLayer/Control/PanelContainer/VBoxContainer/score_container/Top3Container/Top3
	top3.text = "====== TOP 3 ======\n"
	for i in range(min(3, score_list.size())):
		var rank_col := ("#%d" % (i + 1)).rpad(9, " ")
		var name_col := str(score_list[i]["name"]).substr(0, 16).rpad(16, " ")
		var score_col := str(score_list[i]["score"]).lpad(5, " ")
		top3.text+=rank_col+name_col+score_col+"\n"

	var nearbyscores = $CanvasLayer/Control/PanelContainer/VBoxContainer/score_container/VBoxContainer/ScrollContainer/VBoxContainer/NearbyScores
	if my_index == -1:
		nearbyscores.text =("Player not ranked yet\n")
	else:
		nearbyscores.text =("====== AROUND YOU ======\n")

		var start = max(my_index - 100, 0)
		var end = min(my_index + 100, score_list.size() - 1)

		for i in range(start, end + 1):
			var tag := ""
			if i == my_index:
				tag = " <YOU>"

			nearbyscores.text += "#%d  %s  %d  %s\n" % [i + 1, score_list[i].name, score_list[i].score, tag]

func submit_score():
	if Global.player_name == "":
		name_popup.show()
		return 
	if Global.highscore == 0:
		print("not on board getting 0")
		return
	
	await get_tree().process_frame
	last_request_type = "submit"
	var url := "%s/scores/%s.json" % [
		FirebaseConfig.FIREBASE_DB_URL.trim_suffix("/"),
		Global.player_id
	]
	print(url)

	var payload := {
		"name": Global.player_name,
		"score": Global.highscore,
		"timestamp": Time.get_unix_time_from_system()
	}

	var body := JSON.stringify(payload)

	http.request(
		url,
		["Content-Type: application/json"],
		HTTPClient.METHOD_PUT,
		body
	)

#获取排行榜（Top N）
func fetch_top_scores(limit: int = 100000) -> void:
	last_request_type = "fetch"
	await get_tree().process_frame
	var url := "%s/scores.json?orderBy=\"score\"&limitToLast=%d" % [
		FirebaseConfig.FIREBASE_DB_URL,
		limit
	]

	http.request(url)
	
# =========================
# 3️⃣ 统一接收返回
# =========================
func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	await get_tree().process_frame
	if response_code != 200:
		push_error("HTTP Error: %s" % response_code)
		return

	#数据库数据
	var text := body.get_string_from_utf8()
	print("got data = "+text)
	if text.is_empty():
		return

	var parsed: Variant = JSON.parse_string(text)

	if last_request_type == "submit":
		fetch_top_scores()
	else:
		if parsed is Dictionary:
			_process_leaderboard(parsed)
		else:
			push_error("Unexpected JSON format")
		print("Firebase response:", parsed)

func _on_submit_score_pressed():
	submit_score()
	Global.save_game_data()

func _on_main_menu_pressed():
	emit_signal("main_menu")

func _on_try_again_pressed():
	emit_signal("retry_request")

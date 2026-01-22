extends Control

@onready var rank_label: Label = $HBoxContainer/Rank
@onready var name_label: Label = $HBoxContainer/Username
@onready var score_label: Label = $HBoxContainer/Score

func set_data(rank: int, name: String, score: int, is_player = false):
	rank_label.text = format_rank(rank)
	name_label.text = name
	score_label.text = format_score(score)

	if is_player:
		highlight_player()

func highlight_player():
	modulate = Color(1.0, 1.0, 0.7)

func format_rank(rank: int) -> String:
	if rank % 100 in [11, 12, 13]:
		return "%dth" % rank

	match rank % 10:
		1: return "%dst" % rank
		2: return "%dnd" % rank
		3: return "%drd" % rank
		_: return "%dth" % rank

func format_score(score: int) -> String:
	return "%,d" % score

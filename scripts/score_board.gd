extends Node2D

@export var row_scene: PackedScene

@onready var top_3_container = $PanelContainer/MainLayout/Top3Container
@onready var nearby_list = $PanelContainer/MainLayout/NearbySection/ScrollContainer/NearbyPlayersList
@onready var scroll_container = $PanelContainer/MainLayout/NearbySection/ScrollContainer

const WINDOW_SIZE := 25

func sort_with_ranks(entries: Array) -> Array:
	entries.sort_custom(func(a, b): return a.score > b.score)

	var ranked := []
	var last_score = null
	var rank := 0

	for i in range(entries.size()):
		if entries[i].score != last_score:
			rank = i + 1
			last_score = entries[i].score

		ranked.append({
			"rank": rank,
			"name": entries[i].name,
			"score": entries[i].score,
			"is_player": entries[i].is_player
		})

	return ranked

func populate_top_3(ranked: Array):
	for child in top_3_container.get_children():
		child.queue_free()

	for i in range(min(3, ranked.size())):
		var row = row_scene.instantiate()
		var p = ranked[i]
		row.set_data(p.rank, p.name, p.score, p.is_player)
		top_3_container.add_child(row)

func populate_nearby(ranked: Array):
	for child in nearby_list.get_children():
		child.queue_free()

	var player_index := ranked.find(
		ranked.filter(func(p): return p.is_player)[0]
	)

	var start = max(0, player_index - WINDOW_SIZE)
	var end = min(ranked.size(), player_index + WINDOW_SIZE + 1)

	for i in range(start, end):
		var p = ranked[i]
		var row = row_scene.instantiate()
		row.set_data(p.rank, p.name, p.score, p.is_player)
		nearby_list.add_child(row)

		if p.is_player:
			await get_tree().process_frame
			scroll_container.scroll_vertical = row.position.y

extends Node2D
#@export var game_scene: PackedScene

const game_scene := preload("res://scenes/game.tscn")
const score_board_scene := preload("res://scenes/score_board.tscn")
const main_menu_scene := preload("res://scenes/main_menu.tscn")

var current_scene = null
   
func _ready():
	_on_main_menu_called()

func _on_start_pressed():
	_clear_current_scene()
#	get_tree().change_scene_to_packed(game_scene)
	var game = game_scene.instantiate()
	add_child(game)
	current_scene = game
	
	game.game_over.connect(_on_game_over)

func _on_game_over():
	_clear_current_scene()
	var score_board = score_board_scene.instantiate()
	add_child(score_board)
	current_scene = score_board
	
	score_board.retry_request.connect(_on_start_pressed)
	score_board.main_menu.connect(_on_main_menu_called)
	
func _on_main_menu_called():
	_clear_current_scene()
	var main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	current_scene = main_menu
	
	main_menu.start_game.connect(_on_start_pressed)

func _clear_current_scene():
	if current_scene:
		current_scene.queue_free()
		current_scene = null

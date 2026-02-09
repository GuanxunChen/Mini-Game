extends Node2D

@onready var missle_spawner := $MissleSpawner
@onready var DifficultyManager := $DifficultyManager
signal game_over

func _ready():
	missle_spawner.game_over.connect(_on_game_over)

func _on_game_over():
	DifficultyManager.difficulty_level = 1
	DifficultyManager.difficulty_ratio = 0
	DifficultyManager.elapsed_time = 0
	emit_signal("game_over")#在main里接收

extends Node2D

@onready var missle_spawner := $MissleSpawner

signal game_over

func _ready():
	missle_spawner.game_over.connect(_on_game_over)

func _on_game_over():
	emit_signal("game_over")

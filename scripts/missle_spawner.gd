extends Node

@export var missile_scene: PackedScene
@export var spawn_interval: float = 1.0        # 导弹生成间隔（秒）
@export var spawn_x_min: int = 400
@export var spawn_x_max: int = 900
@export var spawn_y_min: int = 400
@export var spawn_y_max: int = 900
@export var red_zone_radius: float = 50.0      # 红圈大小

var timer := 0.0
var score := 0

@onready var score_label := $"../Score"

func _physics_process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_missile()

func spawn_missile():
	if missile_scene == null:
		return

	var missile = missile_scene.instantiate()
	add_child(missile)

	# 随机位置
	var x_pos = randi_range(spawn_x_min, spawn_x_max)
	var y_pos = randi_range(spawn_y_min, spawn_y_max)
	missile.position = Vector2(x_pos, y_pos)

	# 设置红圈大小
	if missile.has_method("set_red_radius"):
		missile.set_red_radius(red_zone_radius)

	# 连接信号
	missile.connect("destroyed", Callable(self, "_on_missile_destroyed"))
	missile.connect("exploded", Callable(self, "_on_missile_exploded"))

func _on_missile_destroyed(_missile):
	score += 1
	if score_label:
		score_label.text = "Score: " + str(score)
	print("Missile destroyed! Score: ", score)

func _on_missile_exploded(_missile):
	print("Missile exploded! Game Over!")
	# TODO: 添加 Game Over 逻辑，例如切换场景、弹出面板

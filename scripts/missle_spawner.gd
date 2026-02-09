extends Node

#@export var score_scene: PackedScene#改为释放信号
signal game_over

@export var missile_scene: PackedScene
@export var spawn_interval: float = 1.5        # 导弹生成间隔（秒）
@export var spawn_x_min: int = 400
@export var spawn_x_max: int = 900
@export var spawn_y_min: int = 400
@export var spawn_y_max: int = 900
@export var red_zone_radius: float = 1.0      # 红圈比例

var current_difficulty = {}
var timer := 0.0

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
	
	#print("spawn_interval:"+str(spawn_interval))
	#print("red_zone_radius:"+str(red_zone_radius))
	
	# 应用难度参数
	if missile.has_method("apply_difficulty"):
		missile.apply_difficulty(current_difficulty)
	
	# 随机位置
	var x_pos = randi_range(spawn_x_min, spawn_x_max)
	var y_pos = randi_range(spawn_y_min, spawn_y_max)
	missile.position = Vector2(x_pos, y_pos)

	# 设置红圈大小
	if missile.has_method("set_red_circle_size"):
		missile.set_red_circle_size(red_zone_radius)

	# 连接信号
	missile.connect("destroyed", Callable(self, "_on_missile_destroyed"))
	missile.connect("exploded", Callable(self, "_on_missile_exploded"))

func _on_missile_destroyed(_missile):
	Global.current_score += 1
	if score_label:
		score_label.text = "Score: " + str(Global.current_score)
	print("Missile destroyed! Score: ", Global.current_score)

func _on_missile_exploded(_missile):
	print("Missile exploded! Game Over!")
	if Global.current_score > Global.highscore:
		Global.highscore = Global.current_score
	Global.current_score = 0
	Global.save_game_data()
	emit_signal("game_over")#game里接收

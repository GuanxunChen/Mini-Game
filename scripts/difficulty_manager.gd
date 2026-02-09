extends Node

@onready var missile_spawner = $"../MissleSpawner"
@onready var player = $"../Player"

# === 难度状态 ===
var elapsed_time := 0.0
var difficulty_ratio := 0.085
var difficulty_level := 1
# === 可调参数 ===
const DIFFICULTY_STEP_TIME := 5.0   #每6秒升级
const MAX_DIFFICULTY := 30

func _process(delta):
	elapsed_time += delta

	var new_level := int(elapsed_time / DIFFICULTY_STEP_TIME)
	new_level = min(new_level, MAX_DIFFICULTY)

	if new_level != difficulty_level:
		print(new_level)
		difficulty_level = new_level
		_apply_difficulty(difficulty_ratio*float(difficulty_level))

func _apply_difficulty(ratio: float) -> void:
	#print("——apply difficulty——")
	if missile_spawner == null:
		return
	
	# === 生成频率（秒）（越小越难）===
	missile_spawner.spawn_interval = min(
		1.5,#default
		3-ratio#根据时间缩减
	)

	# === 红圈半径比例（越小越难）,暂不修改===
	#missile_spawner.red_zone_radius = min(
	#	1,
	#	0.5
	#)

	# === 下发给 missile 的参数 ===
	missile_spawner.current_difficulty = {
		"grow_speed": 0.75+ratio,#3差不多就是极限了
		"destroy_timeout": 5-ratio
	}
	#print("——end apply difficulty——")

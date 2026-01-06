extends Area2D

signal destroyed(missile)
signal exploded(missile)

@export var grow_speed := 0.4        # 导弹放大速度
@export var red_radius := 50.0       # 红圈固定大小
@export var destroy_timeout := 5.0   # 可击破后倒计时秒数

var active := false                   # 是否进入可击破状态
var active_timer := 0.0               # 可击破倒计时

@onready var missile_sprite := $Missile
@onready var red_circle := $RedCircle

func _ready():
	if missile_sprite == null or red_circle == null:
		push_error("Missile scene structure incorrect!")
		return
	
	# 初始化导弹
	missile_sprite.scale = Vector2.ZERO
	red_circle.visible = true

	monitoring = true
	monitorable = true

	# 连接 Area2D 碰撞信号
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if not active:
		grow_missile(delta)
		check_enter_active_state()
	else:
		active_timer += delta
		if active_timer >= destroy_timeout:
			explode()
			
func grow_missile(delta):
	missile_sprite.scale += Vector2.ONE * grow_speed * delta
	
func check_enter_active_state():
	var missile_radius = get_sprite_radius(missile_sprite)
	var red_radius = get_sprite_radius(red_circle)
	
	if missile_radius >= red_radius:
		enter_active_state()

func get_sprite_radius(sprite: Sprite2D) -> float:
	var tex_size = sprite.texture.get_size()
	# 用 X 即可，假设正圆
	return (tex_size.x * sprite.scale.x) * 0.5

func enter_active_state():
	active = true
	active_timer = 0.0
	#print("Missile ACTIVE (can be destroyed)")

func _on_body_entered(body):
	if active and body.is_in_group("player"):
		print("Missile hit player!")  # 调试用
		destroy()

func destroy():
	emit_signal("destroyed", self)
	queue_free()

func explode():
	emit_signal("exploded", self)
	queue_free()

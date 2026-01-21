extends Area2D

signal destroyed(missile)
signal exploded(missile)

@export var grow_speed := 0.4*3        # 导弹放大速度
@export var destroy_timeout := 5.0   # 可击破后倒计时秒数

var active := false                   # 是否进入可击破状态
var active_timer := 0.0               # 可击破倒计时

@onready var missile_sprite := $Missile
@onready var red_circle := $RedCircle
@onready var collision_shape := $CollisionShape2D
@onready var missile_player := $Missile_Player
@onready var red_circle_player := $Red_Circle_Player

func _ready():
	if missile_sprite == null or red_circle == null:
		push_error("Missile scene structure incorrect!")
		return
	
	# 初始化导弹
	set_red_circle_size()
	missile_sprite.scale = Vector2.ZERO
	monitoring = true
	monitorable = true
	
	missile_player.play("Missle_Flying")
#	print("missle:")
#	print((missile_sprite.texture.get_size().x * missile_sprite.scale.x) * 0.5)
#	print(missile_sprite.texture.get_size().x)
#	print(missile_sprite.scale.x)
#	print("red_circle")
#	print((red_circle.texture.get_size().x * red_circle.scale.x) * 0.5)
#	print(red_circle.texture.get_size().x)
#	print(red_circle.scale.x)
	# 连接 Area2D 碰撞信号
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if not active:
		grow_missile(delta)
	else:
		active_timer += delta
		if active_timer >= destroy_timeout:
			explode()

func grow_missile(delta):
	missile_sprite.scale += Vector2.ONE * grow_speed * delta
	check_enter_active_state()

func check_enter_active_state():
	var missile_radius = get_sprite_radius(missile_sprite)
	var red_radius = get_sprite_radius(red_circle)
#	print("radius:")
#	print(missile_radius)
#	print(red_radius)
	if red_radius <= missile_radius:#/2是因为原图只占据了64像素的一部分
		enter_active_state()
		
func set_red_circle_size():
	var viewport_width = get_viewport_rect().size.x
#	print("viewport:")
#	print(viewport_width)
	
	var target_radius = viewport_width / 15.0
#	print("target_radius:")
#	print(target_radius)

	var texture_width = red_circle.texture.get_size().x/3
#	print("text_width:")
#	print(texture_width)
	
	var scale_value = (target_radius * 2.0) / texture_width
#	print("scale:")
#	print(scale_value)
	red_circle.scale = Vector2.ONE * scale_value	
	collision_shape.shape.radius = float(target_radius)	

func get_sprite_radius(sprite: Sprite2D) -> float:
	var tex_size = sprite.texture.get_size()	
	return (tex_size.x * sprite.scale.x) * 0.5

func enter_active_state():
	active = true
	red_circle_player.play("Red_Circle_Enter_Active")
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
	#get_tree().change_scene_to_file("res://scenes/scoreboard.tscn")

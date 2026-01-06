extends CharacterBody2D

@onready var guide_line := $Line2D
var screen_width = 0
var max_drag_px = 0

@export var gravity := 980.0
@export var wall_slide_speed := 120.0
@export var ceiling_hold_time := 3
var ceiling_timer := 0.0


@export var max_charge := 1300.0
var charging := false
var charge_start := Vector2.ZERO

enum GAME_MODE{Campaign, Timed}
var game_mode := GAME_MODE.Timed
@export var max_air_jump := 2
var current_air_jump := max_air_jump

var timer := 0.0
var difficulty_factor := 1.0
var max_difficulty := 2.0
var launch_lock = false

func _ready():
	guide_line.visible = false
	add_to_group("player")
	
	screen_width = get_viewport_rect().size.x
	max_drag_px = screen_width * 0.7
	
	if game_mode == GAME_MODE.Timed:
		max_air_jump = 0
		current_air_jump = max_air_jump

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and is_in_control_area(event.position):
			start_charge(event.position)
		elif not event.pressed and charging:
			release_charge(event.position)
			
	if event is InputEventScreenDrag and charging:
		update_guide(event.position)

func start_charge(pos: Vector2):
	charging = true
	charge_start = pos
	
	if not (is_on_ceiling() or is_on_wall() or is_on_floor()) and current_air_jump == 0:
		guide_line.visible = false
	else:
		guide_line.visible = true

func release_charge(end_pos: Vector2):
	charging = false
	guide_line.visible = false

	var drag_vector = charge_start - end_pos
	var drag_distance = drag_vector.length()
	var ratio = clamp(drag_distance / max_drag_px, 0, 1)
	
	if not (is_on_ceiling() or is_on_wall() or is_on_floor()) and current_air_jump >= 1:
		velocity = drag_vector.normalized() * (ratio * max_charge * difficulty_factor)
		current_air_jump -= 1
		launch_lock = true
	elif is_on_ceiling() or is_on_wall() or is_on_floor():
		velocity = drag_vector.normalized() * (ratio * max_charge * difficulty_factor)
		launch_lock = true

func update_guide(current_pos: Vector2):
	var drag_vector = (charge_start - current_pos)
	var drag_distance = drag_vector.length()
	
	var ratio = clamp(drag_distance / max_drag_px, 0, 1)

	var min_len = 30
	var max_len = 120
	var line_len = min_len + ratio * (max_len - min_len)

	guide_line.clear_points()
	if drag_vector.length() > 10:
		guide_line.add_point(Vector2.ZERO)
		guide_line.add_point(drag_vector.normalized() * line_len)

func _physics_process(delta):
	handle_attach_state(delta)
	move_and_slide()
	apply_gravity(delta)
	
	launch_lock = false
	#每五秒增加难度
	timer += delta
	if timer >= 5.0 and difficulty_factor < max_difficulty:
		difficulty_factor += 0.025
		timer -= 5.0

func handle_attach_state(delta):
	if launch_lock:
		return
	if is_on_ceiling():
		velocity = Vector2.ZERO
		ceiling_timer += delta
		if ceiling_timer >= ceiling_hold_time:
			apply_gravity(delta)
			ceiling_timer = 0.0
		
	if is_on_wall():
		if velocity.y > wall_slide_speed:
			velocity.y = wall_slide_speed
		
	if is_on_floor():
		pass

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func is_in_control_area(pos: Vector2) -> bool:
	var rect = get_viewport_rect().size
	var margin_x = 20 
	return pos.y > rect.y * 0.6 and pos.x > margin_x and pos.x < rect.x - margin_x

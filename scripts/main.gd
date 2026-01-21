extends Node2D
@export var game_scene: PackedScene

func _ready():
	var background = $Background
	var tex_size = background.texture.get_size()
	var viewport_size = get_viewport_rect().size
	
	var scale_x = viewport_size.x / tex_size.x
	var scale_y = viewport_size.y / tex_size.y
	
	var scale = max(scale_x, scale_y)
	background.scale = Vector2.ONE * scale
	AdManager.show_banner()

func _on_start_pressed():
	get_tree().change_scene_to_packed(game_scene)

func _on_quit_pressed():
	get_tree().quit()

#===============================================================================
#Unfinished
#-------------------------------------------------------------------------------

func _on_score_pressed():
	pass # Replace with function body.


func _on_customize_pressed():
	pass # Replace with function body.


func _on_shop_pressed():
	pass # Replace with function body.


func _on_setting_pressed():
	pass # Replace with function body.

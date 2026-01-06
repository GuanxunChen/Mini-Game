extends Node2D
@export var game_scene: PackedScene

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

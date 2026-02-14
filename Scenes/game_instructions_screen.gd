extends Control

# Safety variable which prevents errors linked with buttons pushing by player
var already_pressed = false

func _input(event):
	# Exclude mouse move as a key to click
	if event is InputEventMouseMotion:
		return
		
	# Starting game
	if event.is_pressed() and not already_pressed:
		already_pressed = true
		
		get_tree().change_scene_to_file("res://Scenes/game.tscn")

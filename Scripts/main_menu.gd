extends Control

## Load
func _on_load_button_pressed() -> void:
	## Changing scene to "game"
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

## Start
func _on_start_button_pressed() -> void:
	## Removing save file
	var dir = DirAccess.open("user://")
	if FileAccess.file_exists("user://savegame.tres"):
		dir.remove("savegame.tres")
	
	## Changing scene to "game"
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

## Exit
func _on_exit_button_pressed() -> void:
	get_tree().quit()

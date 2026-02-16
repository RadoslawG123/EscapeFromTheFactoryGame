extends Control

func _on_play_button_pressed() -> void:
	visible = false

func _on_exit_button_pressed() -> void:
	SaverLoader.save_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

extends Control

func _on_play_button_pressed() -> void:
	## Instances
	var playerBody: CharacterBody2D = get_tree().get_first_node_in_group("Player")
	var anim_sprite = playerBody.get_node("AnimatedSprite2D")
	
	# Hide PauseMenuScreen
	visible = false
	
	# Start the game timer
	get_tree().call_group("GameTimer", "start")
	
	# Enable player's physic, controls and animation
	anim_sprite.process_mode = Node.PROCESS_MODE_INHERIT
	playerBody.set_physics_process(true)
	
	# Unfreeze moving blocks
	for movingBlock in get_tree().get_nodes_in_group("MovingBlocks"):
		movingBlock.start_moving()

func _on_exit_button_pressed() -> void:
	SaverLoader.save_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

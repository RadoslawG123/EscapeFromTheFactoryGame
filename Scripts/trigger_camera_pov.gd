extends Node2D

func _on_trigger_camera_pov_entered(body: Node2D) -> void:
	if body.name == "Player":
		change_camera_pov()

func change_camera_pov():
	# Instances
	var camera: Camera2D = get_tree().get_first_node_in_group("Camera")
	var tween = create_tween()
	
	# Set smooth camera tranistion
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# centering the camera on the player
	tween.tween_property(camera, "offset", Vector2(0, 0), 1)

extends Node2D

func _on_trigger_entered(body: Node2D) -> void:
	if body.name == "Player":
		spawn_objects()

func spawn_objects():
	for child in get_children():
		var activate = child.get("activate")
		
		if activate != null:
			child.set("activate", true)
		else:
			print("Activate variable not found in child: ", child)



















#@export var scene_pos: Dictionary[Vector2, PackedScene]

#var inst

#func _process(delta: float) -> void:
	#print("Current_Scene: ", get_tree().current_scene)
	#if inst != null:
		#print("Child added? ", inst.get_parent())
		#print("Position: ", inst.global_position)
		#print(inst.name)

#func _on_trigger_entered(body: Node2D) -> void:
	#if body.name == "Player":
		#spawn_objects()

#func spawn_objects():
	#print("Triggered")
	#for item in scene_pos:
		#inst = scene_pos[item].instantiate()
		##print("Inst: ", inst)
		#call_deferred("_add_instance", inst, item)
		#
#
#func _add_instance(inst, pos):
	#get_tree().current_scene.add_child(inst)
	#inst.position = pos
	##print("Current_Scene: ", get_tree().current_scene)
	##print("Child added? ", inst.get_parent())
	##print("Position: ", inst.global_position)
	
	

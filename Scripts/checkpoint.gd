extends Node2D

@export var player: Player
@onready var sprite: Sprite2D = $Sprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player.checkpointPosition = position
		sprite.texture = preload("res://Assets/Others/Map_Markers_Flagpole.png")

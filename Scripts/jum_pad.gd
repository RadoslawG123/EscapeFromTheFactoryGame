extends Area2D

@export var sprite: AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.jump_pad()
		sprite.play("Activation")

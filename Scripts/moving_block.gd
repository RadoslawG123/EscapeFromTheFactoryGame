extends StaticBody2D

@export var speed: float = 50.0
@export var direction: Vector2 = Vector2.LEFT

func _physics_process(delta: float) -> void:
	position += speed * direction * delta
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Point A" or body.name == "Point B":
		direction *= -1

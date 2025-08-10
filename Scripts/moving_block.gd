extends StaticBody2D

@export var speed: float = 50.0
@export var direction: Vector2 = Vector2.LEFT

func _physics_process(delta: float) -> void:
	position += speed * direction * delta

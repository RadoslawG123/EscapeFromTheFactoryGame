extends AnimatableBody2D

@export var velocity: float = 0.0
@export var startPositionX: float = 0.0
@export var endPositionX: float = 0.0
@export var activate := false

@onready var ob: AnimatableBody2D = $"."


func _physics_process(delta: float) -> void:
	if activate:
		ob.position.x -= velocity
		
	if ob.position.x <= endPositionX:
		ob.position.x = startPositionX

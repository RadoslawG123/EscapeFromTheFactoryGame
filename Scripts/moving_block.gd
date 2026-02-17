extends Path2D

@export var loop := true
@export var speed := 50.0
@export var speed_scale := 1.0
@export var progress_ratio := 0.0

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation: AnimationPlayer = $AnimationPlayer

var prev_speed_scale := speed_scale

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not loop:
		var length = animation.get_animation("move").length
		animation.play("move")
		animation.seek(length * progress_ratio, true)
		animation.speed_scale = speed_scale
		start_moving()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	path.progress += speed * delta

# Freeze moving blocks
func stop_moving():
	set_process(false)
	animation.speed_scale = 0.0

# Unfreeze moving blocks
func start_moving():
	set_process(true)
	animation.speed_scale = speed_scale

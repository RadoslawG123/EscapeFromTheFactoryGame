extends Path2D

@export var loop := true
@export var speed := 50.0
@export var speed_scale := 1.0
@export var progress_ratio := 0.0

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var path_curve: Path2D = $"."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not loop:
		var length = animation.get_animation("move").length
		animation.play("move")
		animation.seek(length * progress_ratio, true)
		animation.speed_scale = speed_scale
		path.progress_ratio = progress_ratio

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	path.progress += speed * delta

#func curve_length():
	#var len: float = 0.0
	#
	#for i in range(0, path_curve.curve.point_count-1):
		#len += sqrt( (path_curve.curve.get_point_position(i).x)**2 + (path_curve.curve.get_point_position(i).y)**2 )
		#
	#return len

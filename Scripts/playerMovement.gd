extends CharacterBody2D

@export var SPEED := 10400
@export var JUMP_VELOCITY := -30000
@export var JUMPPAD_VELOCITY := -38000
@export var START_GRAVITY := 1700
@export var COYOTE_TIME := 100 # in ms
@export var JUMP_BUFFER_TIME := 100 # in ms
@export var JUMP_CUT_MULTIPLIER := 0.4
@export var AIR_HANG_MULTIPLIER := 0.93
@export var AIR_HANG_THRESHOLD := 50
@export var Y_SMOOTHING := 0.8
@export var AIR_X_SMOOTHING := 0.1
@export var MAX_FALL_SPEED := 25000

@export var tile_map: TileMap

@onready var timer1: Timer = $Timer1
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"


enum States {
	IDLE,
	RUN,
	JUMP,
	AIR,
	DEAD,
}

@onready var state: States = States.AIR
var prevVelocity := Vector2.ZERO
var lastFloorMsec := 0
var wasOnFloor := false
var lastJumpQueueMsec: int
var gravity: int = START_GRAVITY
var onTheSpikes := false
var jumpPadActivate := false
var doubleJumpActive := true

func _ready():
	set_meta("tag", "player")

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")

	# Spikes
	var tile_pos = tile_map.local_to_map(global_position)
	var tile_data = tile_map.get_cell_tile_data(0, tile_pos)
	if tile_data and tile_data.get_custom_data("Spikes") == true and onTheSpikes == false:
		die()

	if is_on_floor():
		lastFloorMsec = Time.get_ticks_msec()
	elif state != States.JUMP and state != States.AIR and state != States.DEAD:
		state = States.AIR
		sprite.play("Jump") #fall
	
	match state:
		States.JUMP:
			if not jumpPadActivate:
				velocity.y = JUMP_VELOCITY * delta
				if not doubleJumpActive:
					sprite.play("Jump")
				else:
					sprite.play("AirIdle")
			else:
				velocity.y = JUMPPAD_VELOCITY * delta
				sprite.play("Jump")
			#animPlayer.stop()
			#animPlayer.play("jump")
			state = States.AIR
		States.AIR:
			if is_on_floor():
				jumpPadActivate = false
				doubleJumpActive = true
				state = States.IDLE
				#animPlayer.play("idle") #land
				
			if Input.is_action_just_released("jump"):
				velocity.y *= JUMP_CUT_MULTIPLIER
				
			run(direction, delta)
			velocity.x = lerp(prevVelocity.x, velocity.x, AIR_X_SMOOTHING)
			
			if Input.is_action_just_pressed("jump"):
				# Coyote Time
				if Time.get_ticks_msec() - lastFloorMsec < COYOTE_TIME and not jumpPadActivate and not doubleJumpActive:
					state = States.JUMP
				elif doubleJumpActive and not jumpPadActivate:
					doubleJumpActive = false
					state = States.JUMP
				else:
					lastJumpQueueMsec = Time.get_ticks_msec()
					
			velocity.y += gravity * delta
			if abs(velocity.y) < AIR_HANG_THRESHOLD:
				gravity *= AIR_HANG_MULTIPLIER
			else:
				gravity = START_GRAVITY
		States.IDLE:
			if Time.get_ticks_msec() - lastJumpQueueMsec < JUMP_BUFFER_TIME or Input.is_action_just_pressed("jump"): # jump buffer
				state = States.JUMP
			else:
				velocity.x = 0
				sprite.scale.x = 1
				sprite.play("Idle")
				if direction != 0:
					state = States.RUN
		States.RUN:
			sprite.play("Run")
			run(direction, delta)
			
			if direction == 0:
				state = States.IDLE
			elif Input.is_action_just_pressed("jump"): 
				state = States.JUMP
		States.DEAD:
			velocity.x = 0
			velocity.y = 0

	if not jumpPadActivate:
		velocity.y = lerp(prevVelocity.y, velocity.y, Y_SMOOTHING)
	else:
		velocity.y = lerp(velocity.y, velocity.y, 0.1)
	
	velocity.y = min(velocity.y, MAX_FALL_SPEED * delta)
	
	wasOnFloor = is_on_floor()
	prevVelocity = velocity
	
	move_and_slide()
	
func run(direction, delta):
	velocity.x = SPEED * direction * delta
	if not direction == 0:
		sprite.flip_h = direction < 0
	
func die():
	onTheSpikes = true
	state = States.DEAD
	sprite.play("Die")
	timer1.start()

func jump_pad():
	jumpPadActivate = true
	state = States.JUMP

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()

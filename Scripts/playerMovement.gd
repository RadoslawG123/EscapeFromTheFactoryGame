extends CharacterBody2D

class_name Player

## Exported variables
@export var STARTING_POSITION := Vector2(-14.0, -9.0)
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

## Objects variables
@onready var timer1: Timer = $Timer1
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldawn: Timer = $DashCooldawn

## States variables and enumerations
enum States {
	IDLE,
	RUN,
	JUMP,
	AIR,
	DEAD,
	DASH,
}
@onready var state: States = States.AIR

## Dash variables
var dashSpeed := 15000
var dashDistance := 1000
var isDashing := false
var canDash := true
var prev_direction := 1.0

## Other variables
var prevVelocity := Vector2.ZERO
var lastFloorMsec := 0
var wasOnFloor := false
var lastJumpQueueMsec: int
var gravity: int = START_GRAVITY
var onTheSpikes := false
var jumpPadActivate := false
var doubleJumpActive := true
var deaths: int = 0
var checkpointPosition := STARTING_POSITION

func _ready():
	set_meta("tag", "player")

func _physics_process(delta):
	## Direction
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		prev_direction = direction
	
	if Input.is_action_just_pressed("Reload"):
		get_tree().reload_current_scene()
	
	## Spikes
	var tile_pos = tile_map.local_to_map(global_position)
	var tile_data = tile_map.get_cell_tile_data(0, tile_pos)
	if tile_data and tile_data.get_custom_data("Spikes") == true and onTheSpikes == false:
		die()

	## Falling and calculating time for coyote time
	if is_on_floor():
		lastFloorMsec = Time.get_ticks_msec()
	elif state != States.JUMP and state != States.AIR and state != States.DEAD and state != States.DASH:
		state = States.AIR
		sprite.play("Jump") #fall
	
	## All States 
	match state:
		## Jump
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

			state = States.AIR
		## Air
		States.AIR:
			## Action - Dash
			if Input.is_action_just_pressed("dash") and not isDashing and canDash:
				isDashing = true
				state = States.DASH
			
			## On the floor
			if is_on_floor():
				canDash = true
				jumpPadActivate = false
				doubleJumpActive = true
				state = States.IDLE
			
			## Jump cut by multiplier
			if Input.is_action_just_released("jump"):
				velocity.y *= JUMP_CUT_MULTIPLIER
			
			## Smooth air movement of X axis
			run(direction, delta)
			velocity.x = lerp(prevVelocity.x, velocity.x, AIR_X_SMOOTHING)
			
			## Action - Jump
			if Input.is_action_just_pressed("jump"):
				## Coyote Time
				if Time.get_ticks_msec() - lastFloorMsec < COYOTE_TIME and not jumpPadActivate and not doubleJumpActive:
					state = States.JUMP
				elif doubleJumpActive and not jumpPadActivate:
					doubleJumpActive = false
					state = States.JUMP
				else:
					lastJumpQueueMsec = Time.get_ticks_msec()
			
			## Gravity
			velocity.y += gravity * delta
			if abs(velocity.y) < AIR_HANG_THRESHOLD:
				gravity *= AIR_HANG_MULTIPLIER
			else:
				gravity = START_GRAVITY
		## Dash
		States.DASH:
			dash(delta)
		## Idle
		States.IDLE:
			## Action - Dash
			#if Input.is_action_just_pressed("dash") and not isDashing and canDash:
					#isDashing = true
					#state = States.DASH
			
			## Action - Jump or Run
			if Time.get_ticks_msec() - lastJumpQueueMsec < JUMP_BUFFER_TIME or Input.is_action_just_pressed("jump"): # jump buffer
				state = States.JUMP
			else:
				velocity.x = 0
				sprite.play("Idle")
				if direction != 0:
					state = States.RUN
		## Run
		States.RUN:
			## Action - Dash
			#if Input.is_action_just_pressed("dash") and not isDashing and canDash:
				#isDashing = true
				#state = States.DASH
				
			sprite.play("Run")
			run(direction, delta)
			
			## State changes to IDLE or JUMP
			if direction == 0:
				state = States.IDLE
			elif Input.is_action_just_pressed("jump"): 
				state = States.JUMP
		## Dead
		States.DEAD:
			velocity.x = 0
			velocity.y = 0

	## Y position smoothing
	if not jumpPadActivate:
		velocity.y = lerp(prevVelocity.y, velocity.y, Y_SMOOTHING)
	else:
		velocity.y = lerp(velocity.y, velocity.y, 0.1)
	
	## Max falling speed
	velocity.y = min(velocity.y, MAX_FALL_SPEED * delta)
	
	## Others
	wasOnFloor = is_on_floor()
	prevVelocity = velocity
	move_and_slide()

## Functions
func dash(delta):
	if isDashing:
		canDash = false
		isDashing = false
		dash_timer.start()
		dash_cooldawn.start()
		
	sprite.play("Dash")
	velocity.x = SPEED*2 * prev_direction * delta
	velocity.y = 0

func run(direction, delta):
	velocity.x = SPEED * direction * delta
	if not direction == 0:
		sprite.flip_h = direction < 0
	
func die():
	deaths += 1
	onTheSpikes = true
	state = States.DEAD
	
	sprite.play("Die")
	timer1.start()

func jump_pad():
	jumpPadActivate = true
	state = States.JUMP

## Timeout - dieing
func _on_timer_timeout() -> void:
	onTheSpikes = false
	state = States.IDLE
	position = checkpointPosition

## Timeout - changing state after dash perform
func _on_dash_timer_timeout() -> void:
	print("Dash ends")
	if is_on_floor():
		canDash = true
		state = States.IDLE
	else:
		state = States.AIR
		sprite.play("AirIdle")

### Timeout - dash cooldawn
#func _on_dash_cooldawn_timeout() -> void:
	#canDash = true

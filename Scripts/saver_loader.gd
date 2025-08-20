class_name SaverLoader
extends Node

## Instances
@onready var player: Player = %Player
@onready var gui: Control = %GUI


func _ready() -> void:
	if FileAccess.file_exists("user://savegame.tres"):
		load_game()
	else:
		print("Game not load.")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Save"):
		save_game()
	if Input.is_action_just_pressed("Exit"):
		load_game()

func save_game():
	var saved_game: SavedGame = SavedGame.new()

	saved_game.checkpoint_position = player.checkpointPosition
	saved_game.deaths = player.deaths
	saved_game.game_time = gui.seconds
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	
func load_game():
	var saved_game:SavedGame = load("user://savegame.tres")
	
	player.position = saved_game.checkpoint_position
	player.deaths = saved_game.deaths
	gui.seconds = saved_game.game_time

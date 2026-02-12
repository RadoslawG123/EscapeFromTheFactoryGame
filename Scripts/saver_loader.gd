extends Node

func _ready() -> void:
	if FileAccess.file_exists("user://savegame.tres"):
		load_game()
	else:
		print("Game not load.")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		save_game()

func save_game():
	## Instances
	var player: Player = get_tree().get_first_node_in_group("Player")
	var gui: Control = get_tree().get_first_node_in_group("GUI")
	
	## Checking if player and gui are rechable
	if player == null or gui == null:
		return
	
	var saved_game: SavedGame = SavedGame.new()

	saved_game.checkpoint_position = player.checkpointPosition
	saved_game.deaths = player.deaths
	saved_game.game_time = gui.seconds
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	print("The game is saved!")
	
func load_game():
	## Instances
	var player: Player = get_tree().get_first_node_in_group("Player")
	var gui: Control = get_tree().get_first_node_in_group("GUI")
	
	## Checking if player and gui are rechable
	if player == null or gui == null:
		return
	
	var saved_game:SavedGame = load("user://savegame.tres")
	
	player.position = saved_game.checkpoint_position
	player.deaths = saved_game.deaths
	gui.seconds = saved_game.game_time

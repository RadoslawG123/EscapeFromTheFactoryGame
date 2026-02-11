extends Area2D

# ZMIENNE GRACZA I GUI
@onready var player: Player = %Player
@onready var gui: Control = %GUI
@onready var victory_text: Control = %VictoryText

# ZMIENNE DO TEKSTÓW Z KOŃCOWEGO EKRANU
@onready var your_deaths_label: Label = victory_text.get_node("%YourDeathsLabel")
@onready var your_time_label: Label = victory_text.get_node("%YourTimeLabel")
@onready var best_deaths_label: Label = victory_text.get_node("%BestDeathsLabel")
@onready var best_time_label: Label = victory_text.get_node("%BestTimeLabel")

# ZMIENNE DO PRZYPISANIA W INSPEKTORZE
@export var playerBody: CharacterBody2D  # Przeciągnij tu swojego graacza
@export var camera: Camera2D         # Przeciągnij tu kamerę (zazwyczaj dziecko gracza)
@export var ui_victory_label: Control # Przeciągnij tu Label lub CanvasLayer z napisem

# USTAWIENIA ANIMACJI
@export var zoom_target := Vector2(2.5, 2.5) # Docelowe oddalenie (im większa liczba tym dalej)
@export var pan_offset_y := -50.0 # O ile pikseli kamera ma iść w górę (minus to góra)
@export var animation_duration := 10.0 # Czas trwania animacji w sekundach

var has_triggered = false
var records_path = "user://records.tres"

func _ready():
	# Podłączamy sygnał wejścia w strefę (można też to zrobić w edytorze)
	body_entered.connect(_on_body_entered)
	ui_victory_label.visible = false

func _on_body_entered(body):
	# Sprawdzamy, czy w strefę wszedł gracz i czy to pierwszy raz
	if body == playerBody and not has_triggered:
		has_triggered = true
		ui_victory_label.visible = true
		start_end_sequence()

func start_end_sequence():
	print("Koniec gry! Odpalam sekwencję.")
	
	get_tree().call_group("GameTimer", "stop")
	
	# 0. Zapisanie rezultatów gry
	save_game_results()
	
	# 1. ZATRZYMANIE GRACZA
	# Wyłączamy fizykę gracza, żeby przestał reagować na klawisze i grawitację
	playerBody.set_physics_process(false)
	# Zerujemy prędkość, żeby nie "leciał" siłą rozpędu jeśli wpadł szybko
	playerBody.velocity = Vector2.ZERO 
	# Opcjonalnie: Jeśli masz animację "Idle", wymuś ją tutaj:
	playerBody.get_node("AnimatedSprite2D").play("Idle")

	# 2. ANIMACJA KAMERY (TWEEN)
	# Tworzymy tweena
	var tween = create_tween()
	# set_parallel(true) sprawia, że zoom i ruch wykonają się JEDNOCZEŚNIE
	tween.set_parallel(true)
	# Ustawiamy typ animacji na 'SINE' (miękki start i stop)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	# Animujemy ZOOM
	tween.tween_property(camera, "zoom", zoom_target, animation_duration)
	
	# Animujemy OFFSET (przesunięcie kamery względem gracza)
	# Używamy offsetu, bo kamera jest pewnie przyczepiona do gracza
	var new_offset = camera.offset + Vector2(0, pan_offset_y)
	tween.tween_property(camera, "offset", new_offset, animation_duration)

	# 3. POKAZANIE NAPISU
	load_game_results()
	
	# Możemy dodać opóźnienie, żeby napis pojawił się np. w połowie ruchu kamery
	await get_tree().create_timer(3.0).timeout
	ui_victory_label.visible = true
	
	# Tutaj w przyszłości dodasz kod do pokazania tablicy wyników
	
func save_game_results():
	var saved_records: SavedRecords
	
	if FileAccess.file_exists(records_path):
		saved_records = load(records_path) as SavedRecords
	else: 
		saved_records = SavedRecords.new()
	
	if player.deaths < saved_records.deaths_record:
		saved_records.deaths_record = player.deaths
	
	if gui.seconds < saved_records.game_time_record:
		saved_records.game_time_record = gui.seconds
	
	ResourceSaver.save(saved_records, records_path)
	
func load_game_results():
	var saved_records: SavedRecords = load(records_path)
	
	var h = int(gui.seconds / 3600)
	var m = int(gui.seconds / 60) - h * 60
	var s = gui.seconds - m * 60 - h * 3600
	your_deaths_label.text = "Your deaths: " + str(player.deaths)
	your_time_label.text = "Your time: %02d:%02d:%02d" % [h, m, s]
	
	h = int(saved_records.game_time_record / 3600)
	m = int(saved_records.game_time_record / 60) - h * 60
	s = saved_records.game_time_record - m * 60 - h * 3600
	best_deaths_label.text = "Best deaths: " + str(saved_records.deaths_record)
	best_time_label.text = "Best time: %02d:%02d:%02d" % [h, m, s]

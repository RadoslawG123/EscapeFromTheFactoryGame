extends Area2D

# ZMIENNE DO PRZYPISANIA W INSPEKTORZE
@export var player: CharacterBody2D  # Przeciągnij tu swojego gracza
@export var camera: Camera2D         # Przeciągnij tu kamerę (zazwyczaj dziecko gracza)
@export var ui_victory_label: Control # Przeciągnij tu Label lub CanvasLayer z napisem

# USTAWIENIA ANIMACJI
@export var zoom_target := Vector2(2.5, 2.5) # Docelowe oddalenie (im większa liczba tym dalej)
@export var pan_offset_y := -50.0 # O ile pikseli kamera ma iść w górę (minus to góra)
@export var animation_duration := 10.0 # Czas trwania animacji w sekundach

var has_triggered = false

func _ready():
	# Podłączamy sygnał wejścia w strefę (można też to zrobić w edytorze)
	body_entered.connect(_on_body_entered)
	ui_victory_label.visible = false

func _on_body_entered(body):
	# Sprawdzamy, czy w strefę wszedł gracz i czy to pierwszy raz
	if body == player and not has_triggered:
		has_triggered = true
		ui_victory_label.visible = true
		start_end_sequence()

func start_end_sequence():
	print("Koniec gry! Odpalam sekwencję.")
	
	# 1. ZATRZYMANIE GRACZA
	# Wyłączamy fizykę gracza, żeby przestał reagować na klawisze i grawitację
	player.set_physics_process(false)
	# Zerujemy prędkość, żeby nie "leciał" siłą rozpędu jeśli wpadł szybko
	player.velocity = Vector2.ZERO 
	# Opcjonalnie: Jeśli masz animację "Idle", wymuś ją tutaj:
	player.get_node("AnimatedSprite2D").play("Idle")

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
	# Możemy dodać opóźnienie, żeby napis pojawił się np. w połowie ruchu kamery
	await get_tree().create_timer(0.5).timeout
	ui_victory_label.visible = true
	
	# Tutaj w przyszłości dodasz kod do pokazania tablicy wyników

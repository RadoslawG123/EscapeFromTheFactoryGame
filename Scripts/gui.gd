extends Control

@onready var deathsLabel: Label = $MarginContainer/VBoxContainer/DeathsLabel
@onready var timeLabel: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var timer: Timer = $Timer

var start: bool = false
var seconds: int = 0
var h: int
var m: int
var s: int

@export var player: Player

func _process(delta: float) -> void:
	update()

func _on_timer_timeout() -> void:
	seconds += 1
	
	h = int(seconds / 3600)
	m = int(seconds / 60) - h * 60
	s = seconds - m * 60 - h * 3600

func update():
	deathsLabel.text = "Deaths: " + str(player.deaths)
	
	if seconds > 0:
		if seconds < 3600:
			timeLabel.text = "Time: " + "%02d:%02d" % [m, s]
		else:
			timeLabel.text = "Time: " + "%02d:%02d:%02d" % [h, m, s]

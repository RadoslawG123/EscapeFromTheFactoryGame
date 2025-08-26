extends Area2D

@onready var control: Control = $Control
@onready var label: Label = $Control/TextureRect/Label
@export var text: String

func _ready() -> void:
	control.visible = false

func _on_information_board_entered(body: Node2D) -> void:
	if body.name == "Player":
		label.text = text
		control.visible = true
		print("SHOWING")


func _on_information_board_exited(body: Node2D) -> void:
	if body.name == "Player":
		control.visible = false

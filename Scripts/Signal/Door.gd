extends Node

class_name  Door

func _ready() -> void:
	var character = $"../Character"
	character.health_depleted.connect(_open_door)

func _open_door():
	print("Open")

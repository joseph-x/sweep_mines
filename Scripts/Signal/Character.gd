extends Node

class_name  Character

signal health_depleted

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			print("T key is down")
			health_depleted.emit()

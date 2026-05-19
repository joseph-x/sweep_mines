extends Node

func _input(event: InputEvent) -> void:
	# print(event.as_text())
	if event.is_action_pressed("my_action"):
		print("my_action occurred!")

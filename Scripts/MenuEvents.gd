extends Node

#region Events

func _on_newgame_pressed() -> void:
	var packed_next_scene = ResourceLoader.load(Constants.SCENE_PATHS.GameScene)
	get_tree().change_scene_to_packed(packed_next_scene)
	pass
	
	
func _on_continuegame_pressed() -> void:
	pass

# Quit Button On Press Event
func _on_quit_pressed() -> void:
	# print(PlayerVariables.health)
	# PlayerVariables.health = PlayerVariables.health - 1
	get_tree().quit()

#endregion

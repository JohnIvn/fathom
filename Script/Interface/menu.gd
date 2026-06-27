extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Nodes/Map/debug.tscn")

func _on_options_pressed() -> void:
	pass

func _on_exit_pressed():
	get_tree().quit()

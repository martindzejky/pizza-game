extends Control

func _onClicked():
    Effects.sound("click")
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/end.tscn")

func _on_mouse_entered():
    Effects.sound("hover")

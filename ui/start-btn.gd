extends Control


func _onClicked():
    Effects.sound("click")
    get_tree().change_scene_to_file("res://scenes/level.tscn")

func _onHover():
    Effects.sound("hover")

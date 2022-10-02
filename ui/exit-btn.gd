extends Control
class_name ExitBtn

func _onClicked():
    get_tree().quit()

func _on_mouse_entered():
    Effects.sound("hover")

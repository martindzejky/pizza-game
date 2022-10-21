extends Control
class_name ExitBtn

func _onClicked():
    Effects.sound("click")
    get_tree().quit()

func _onHover():
    Effects.sound("hover")

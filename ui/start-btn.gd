extends Control


func _onClicked():
    Effects.sound("click")

    Days.day += 1
    Transitions.transitionTo("res://scenes/level.tscn", "Day " + str(Days.day))

func _onHover():
    Effects.sound("hover")

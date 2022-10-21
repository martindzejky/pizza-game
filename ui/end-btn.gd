extends Control

func _onClicked():

    # reset carried items
    Hand.reset()

    # submit pizza on the plate if there's any
    get_tree().call_group("plate", "submitPizza")
    # finalize all animating orders
    get_tree().call_group("order-animating", "finalizeOrder")

    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/end.tscn")

    Effects.sound("click")

func _onHover():
    Effects.sound("hover")

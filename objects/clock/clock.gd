extends Node2D


func _on_timer_timeout():
    # reveal mouse if hidden
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    # reset carried items
    Hand.reset()

    # submit pizza on the plate if there's any
    get_tree().call_group("plate", "submitPizza")
    # finalize all animating orders
    get_tree().call_group("order-animating", "finalizeOrder")

    get_tree().change_scene_to_file("res://scenes/end.tscn")

extends Control

func _onClicked():

    # reset carried items
    Hand.reset()

    # submit pizza on the plate if there's any
    get_tree().call_group("plate", "submitPizza")
    # finalize all animating orders
    get_tree().call_group("order-animating", "finalizeOrder")

    Transitions.transitionTo("res://scenes/end.tscn", "Day ended")

    Effects.sound("click")

func _onHover():
    Effects.sound("hover")

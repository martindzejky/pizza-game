extends Node2D


func _on_timer_timeout():
    # reveal mouse if hidden
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    # reset carried items
    Hand.reset()

    # stop the animation of the hands
    get_parent().get_node("smallHandAnimation").stop()
    get_parent().get_node("largeHandAnimation").stop()

    # fail all remaining orders
    get_tree().call_group("order", "fail")

    # pause
    get_tree().paused = true

    # make sure that the music continues
    get_tree().call_group("music", "set_process_mode", PROCESS_MODE_ALWAYS)

    # play a sounds and wait a little
    Effects.sound("dayEnd")
    await get_tree().create_timer(3).timeout

    # submit pizza on the plate if there's any
    get_tree().call_group("plate", "submitPizza")
    # finalize all animating orders
    get_tree().call_group("order-animating", "finalizeOrder")

    Transitions.transitionTo("res://scenes/end.tscn", "Day ended")

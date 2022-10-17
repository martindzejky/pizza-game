extends Control


func _on_gui_input(event: InputEvent):

    # only care about left mouse clicks (on release)
    if not event is InputEventMouseButton: return
    if event.button_index != MOUSE_BUTTON_LEFT: return
    if not event.is_pressed(): return

    for child in $container/center/order.get_children():
        if "_onClick" in child:
            child._onClick()

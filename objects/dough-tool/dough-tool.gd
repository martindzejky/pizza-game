extends Pickable


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:

                if Hand.isEmpty():
                    Hand.pick(self)
                    viewport.set_input_as_handled()

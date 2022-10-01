extends Sprite2D


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:

                if not Hand.isEmpty():
                    Hand.drop()
                    viewport.set_input_as_handled()

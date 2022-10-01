extends Pickable


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                if isPicked:
                    # drop the dough
                    Hand.drop()

                elif Hand.isEmpty():
                    # pick the dough
                    Hand.pick(self)

                else:
                    pass
                    # TODO: interactions with other objects

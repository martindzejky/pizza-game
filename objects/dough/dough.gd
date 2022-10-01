extends Pickable


func _init() :
    # start as picked because the dough is created by picking one from the fridge
    isPicked = true


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                if isPicked:
                    # drop the dough
                    isPicked = false
                    Hand.drop()

                elif Hand.isEmpty():
                    # pick the dough
                    isPicked = true
                    Hand.pick(self)

                else:
                    pass
                    # TODO: interactions with other objects

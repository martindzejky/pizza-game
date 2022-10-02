extends Node2D


@export var ingredient: PackedScene


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return
    # cannot put anything into the box
    if not Hand.isEmpty(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                viewport.set_input_as_handled()


                # spawn a new ingredient that is picked
                var ing = ingredient.instantiate()
                get_tree().call_group("table", "add_child", ing)
                Hand.pick(ing)

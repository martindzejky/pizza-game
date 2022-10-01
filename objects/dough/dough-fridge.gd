extends Node2D


@export var doughObject: PackedScene


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return
    if not Hand.isEmpty(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                # destroy this object
                viewport.set_input_as_handled()
                queue_free()

                # spawn a new dough that is picked
                var dough = doughObject.instantiate()
                get_tree().call_group("table", "add_child", dough)
                Hand.pick(dough)

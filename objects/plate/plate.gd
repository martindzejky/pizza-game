extends Sprite2D



func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:

                if Hand.isCarryingDough():
                    if insertDough():
                        viewport.set_input_as_handled()


func insertDough() -> bool:
    if $submitAnimation.is_playing(): return false

    # only one dough can be on the plate
    for node in get_children():
        if node.is_in_group("dough"):
            return false

    var dough = Hand.drop()
    if not dough: return false

    if dough.get_parent():
        dough.get_parent().remove_child(dough)

    add_child(dough)
    dough.set_global_transform(get_global_transform())

    # disable click area to stop further interactions
    dough.get_node("clickArea").queue_free()

    $submitAnimation.play("submit")

    return true


func submitPizza() -> void:
    # TODO: score the pizza and make a screenshot of it

    for node in get_children():
        if node.is_in_group("dough"):

            if node.get_parent():
                node.get_parent().remove_child(node)

            Pizzas.add_child(node)

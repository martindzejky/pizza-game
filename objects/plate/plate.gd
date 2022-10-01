extends Sprite2D


func insertDough(dough: Pickable) -> bool:
    if $submitAnimation.is_playing(): return false

    # only one dough can be on the plate
    for node in get_children():
        if node.is_in_group("dough"):
            return false

    if dough.isPicked:
        Hand.drop()

    if dough.get_parent():
        dough.get_parent().remove_child(dough)

    add_child(dough)
    dough.set_global_transform(get_global_transform())

    $submitAnimation.play("submit")

    return true

func submitPizza() -> void:
    # TODO: score the pizza and make a screenshot of it

    for node in get_children():
        if node.is_in_group("dough"):
            node.queue_free()

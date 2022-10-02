extends Sprite2D

@export var closedSprite: Texture2D
@export var openSprite: Texture2D


var isOpen := false


func _process(delta: float) -> void:
    if not isOpen:

        # cook all dough inside
        for node in get_children():
            if not node.is_in_group("dough"): continue

            node.cookProgress += delta

            # cook all ingredients on the dough
            for doughNode in node.get_children():
                if not doughNode.is_in_group("ingredient"): continue

                doughNode.cookProgress += delta


func _onClick() -> bool:
    if Hand.isCarryingDough():
        if insertDough():
            return true

    if Hand.isEmpty():
        if isOpen:
            close()
        else:
            open()

        return true

    return false


func open() -> void:
    isOpen = true
    texture = openSprite

    # reveal all dough inside
    for node in get_children():
        if node.is_in_group("dough"):
            node.visible = true

func close() -> void:
    isOpen = false
    texture = closedSprite

    # hide all dough inside
    for node in get_children():
        if node.is_in_group("dough"):
            node.visible = false


func insertDough() -> bool:
    if not isOpen: return false

    # only one dough can be inside at a time
    for node in get_children():
        if node.is_in_group("dough"):
            return false

    var dough = Hand.drop()
    if not dough: return false

    if dough.get_parent():
        dough.get_parent().remove_child(dough)

    add_child(dough)
    dough.set_global_transform($point.get_global_transform())

    return true

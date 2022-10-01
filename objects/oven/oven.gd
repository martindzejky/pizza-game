extends Sprite2D

@export var closedSprite: Texture2D
@export var openSprite: Texture2D


var isOpen := false

func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:

                if Hand.isEmpty():
                    if isOpen:
                        close()
                    else:
                        open()

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

func insertDough(dough: Pickable) -> bool:
    if not isOpen: return false

    # only one dough can be inside at a time
    for node in get_children():
        if node.is_in_group("dough"):
            return false

    if dough.isPicked:
        Hand.drop()

    if dough.get_parent():
        dough.get_parent().remove_child(dough)

    add_child(dough)
    dough.set_global_transform($point.get_global_transform())
    return true

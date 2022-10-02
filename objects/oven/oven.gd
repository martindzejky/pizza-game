extends Sprite2D

@export var closedSprite: Texture2D
@export var openSprite: Texture2D


var isOpen := false


func _process(delta: float) -> void:
    $particles.emitting = false

    if not isOpen:

        # cook all dough inside
        for node in get_children():
            if not node.is_in_group("dough"): continue

            node.cookProgress += delta

            # cook all ingredients on the dough
            for doughNode in node.get_children():
                if not doughNode.is_in_group("ingredient"): continue

                doughNode.cookProgress += delta

            # smoke if overcooked (#reference)
            if node.isCookReady():
                $particles.emitting = true
                $particles.amount = 3
            elif node.isCookOvercooked():
                $particles.emitting = true
                $particles.amount = 15


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
    Effects.sound("ovenOpen")

    # reveal all dough inside
    for node in get_children():
        if node.is_in_group("dough"):
            node.visible = true

func close() -> void:
    isOpen = false
    texture = closedSprite
    Effects.sound("ovenClose")

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

    # squash and position
    if dough.progress < 4:
        dough.scale.y = lerp(1.0, 0.5, dough.progress / 4.0)
        dough.position.y -= lerp(10.0, 0.0, dough.progress / 4.0)
    else:
        dough.scale.y = 0.5

    return true

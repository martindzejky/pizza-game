extends Sprite2D

@export var closedSprite: Texture2D
@export var openSprite: Texture2D


var isOpen := false
var wasReady := false


func _process(delta: float) -> void:

    var isCooking := false

    if not isOpen:

        # cook all dough inside
        for node in get_children():
            if not node.is_in_group("dough"): continue

            isCooking = true
            node.cookProgress += delta

            # cook all ingredients on the dough
            for doughNode in node.get_children():
                if not doughNode.is_in_group("ingredient"): continue

                doughNode.cookProgress += delta

            # smoke if overcooked (#reference)
            if node.isCookReady():
                $particles.emitting = true
                $particles.amount = 4
            elif node.isCookOvercooked():
                $particles.emitting = true
                $particles.amount = 15

            # beep when done
            if not wasReady and node.isCookReady():
                Effects.sound("ovenBeep")
                wasReady = true
                $ovenLight/animations.play("blink")

            if $ovenLight/animations.current_animation == "off":
                $ovenLight/animations.play("on")

    if not isCooking:
        $particles.emitting = false

        if $ovenLight/animations.current_animation != "off":
            $ovenLight/animations.play("off")


func _onClick() -> bool:
    if Hand.isCarryingDough():
        if insertDough():
            Effects.sound("drop")
            return true

    if Hand.isEmpty():
        if isOpen:
            close()
        else:
            open()

        return true

    # special case: if carrying an item and the oven is closed,
    # allow to open it
    elif not isOpen:
        open()
        return true

    return false


func open() -> void:
    isOpen = true
    wasReady = false
    texture = openSprite
    Effects.sound("ovenOpen")

    # reveal all dough inside
    for node in get_children():
        if node.is_in_group("dough"):
            node.visible = true

    # burst particles
    var burstParticles: GPUParticles2D = $particles.duplicate()
    add_child(burstParticles)

    burstParticles.emitting = true
    burstParticles.amount = randi() % 6 + 10
    burstParticles.one_shot = true
    burstParticles.explosiveness = 1

    await get_tree().create_timer(burstParticles.lifetime).timeout
    burstParticles.queue_free()


func close() -> void:
    isOpen = false
    wasReady = false
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

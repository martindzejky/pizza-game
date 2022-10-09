extends Sprite2D

@export var closedSprite: Texture2D
@export var openSprite: Texture2D

@export var dough: PackedScene

var isOpen := false


func _onClick() -> bool:
    if not Hand.isEmpty():
        # special case: if carrying an item and the oven is closed,
        # allow to open it
        if not isOpen:
            open()
            return true

        # cannot put anything into the fridge
        return false

    if isOpen:
        close()
    else:
        open()

    return true

# open the fridge and spawn a new dough
func open() -> void:
    Effects.sound("fridgeOpen")

    isOpen = true
    texture = openSprite

    var newDough = dough.instantiate()
    newDough.transform = $spawnPoint.transform
    add_child(newDough)

    # burst particles
    var burstParticles: GPUParticles2D = $particles.duplicate()
    add_child(burstParticles)

    burstParticles.emitting = true
    burstParticles.amount = randi() % 6 + 6
    burstParticles.one_shot = true
    burstParticles.explosiveness = 1

    await get_tree().create_timer(burstParticles.lifetime).timeout
    burstParticles.queue_free()

# close the fridge and destroy the dough inside if there is any
func close() -> void:
    $particles.emitting = false
    Effects.sound("fridgeClose")

    isOpen = false
    texture = closedSprite

    for node in get_tree().get_nodes_in_group("dough-fridge"):
        node.queue_free()

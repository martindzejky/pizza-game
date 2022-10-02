extends Sprite2D

@export var closedSprite: Texture2D
@export var openSprite: Texture2D

@export var dough: PackedScene

var isOpen := false


func _onClick() -> bool:
    # cannot put anything into the fridge
    if not Hand.isEmpty(): return false

    if isOpen:
        close()
    else:
        open()

    return true

# open the fridge and spawn a new dough
func open() -> void:
    isOpen = true
    texture = openSprite

    var newDough = dough.instantiate()
    newDough.transform = $spawnPoint.transform
    add_child(newDough)

# close the fridge and destroy the dough inside if there is any
func close() -> void:
    isOpen = false
    texture = closedSprite

    for node in get_tree().get_nodes_in_group("dough-fridge"):
        node.queue_free()

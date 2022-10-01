extends Sprite2D

@export var closedSprite: Texture2D
@export var openSprite: Texture2D

@export var dough: PackedScene

var isOpen: bool = false


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if viewport.is_input_handled(): return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if not event.pressed:
                if isOpen:
                    close()
                else:
                    open()

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

    for dough in get_tree().get_nodes_in_group("dough-fridge"):
        dough.queue_free()

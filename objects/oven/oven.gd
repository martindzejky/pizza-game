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

                else:
                    # TODO: interactions
                    pass

func open() -> void:
    isOpen = true
    texture = openSprite

func close() -> void:
    isOpen = false
    texture = closedSprite

extends Sprite2D

@export var closedSprite: Texture2D
@export var openSprite: Texture2D

var isOpen: bool = false


func _onInputEvent(viewport: Node, event: InputEvent, shapeId: int) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.is_pressed():
                isOpen = !isOpen
                if isOpen:
                    texture = openSprite
                else:
                    texture = closedSprite

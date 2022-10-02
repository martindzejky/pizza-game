extends Pickable


@export var fullSprite: Texture2D
@export var emptySprite: Texture2D

@export var isFull: bool = true


func _onClick() -> bool:
    if Hand.isEmpty():
        Hand.pick(self)
        Effects.sound("pickupTool")
        return true

    return false

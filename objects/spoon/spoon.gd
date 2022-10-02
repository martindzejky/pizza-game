extends Sprite2D

func _onClick() -> bool:
    if Hand.isEmpty():
        Hand.pick(self)
        Effects.sound("pickupTool")
        return true

    return false

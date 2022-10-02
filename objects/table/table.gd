extends Sprite2D


func _onClick() -> bool:
    if not Hand.isEmpty():
        Hand.drop()
        Effects.sound("drop")
        return true

    return false

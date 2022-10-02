extends Sprite2D


func _onClick() -> bool:
    if not Hand.isEmpty():
        Hand.drop()
        return true

    return false

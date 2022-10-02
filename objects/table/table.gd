extends Sprite2D


func _onClick() -> bool:
    if not Hand.isEmpty():
        Hand.drop()
        $dropSound.play()
        return true

    return false

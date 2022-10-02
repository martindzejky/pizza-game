extends Pickable


func _onClick() -> bool:
    if Hand.isEmpty():
        Hand.pick(self)
        return true

    return false

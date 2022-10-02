extends Node2D


@export var withoutSpoon: Texture2D
@export var withSpoon: Texture2D
@export var spoonObj: PackedScene

@export var hasSpoon := false


func _onClick() -> bool:
    if Hand.isEmpty() and hasSpoon:
        Effects.sound("pickupTool")

        var spoon = spoonObj.instantiate()
        get_tree().call_group("table", "add_child", spoon)
        Hand.pick(spoon)

        hasSpoon = false
        $sprite.texture = withoutSpoon

        return true

    elif Hand.isCarryingSpoon():
        Effects.sound("drop")

        Hand.drop().queue_free()
        hasSpoon = true
        $sprite.texture = withSpoon

        return true


    return false

extends Node2D


@export var ingredient: PackedScene


func _onClick() -> bool:
    # cannot put anything into the box
    if not Hand.isEmpty(): return false

    # spawn a new ingredient that is picked
    var ing = ingredient.instantiate()
    get_tree().call_group("table", "add_child", ing)
    Hand.pick(ing)

    Effects.sound("pickup")

    return true
